<p align="center">
  <img src="seaturtle_logo.jpg" alt="SEATURTLE Logo" width="500">
</p>

<p align="center">
  <img src="seaturtle.jpg" alt="SEATURTLE - la scheda" width="500">
</p>

# SEATURTLE — Tiny lightweight LED controller for R/C models

SEATURTLE è una centralina luci pensata per essere il più piccola e leggera possibile: monta tutti i componenti in SMD su un PCB di pochi millimetri, con un solo connettore di ingresso dalla ricevente e quattro uscite per i LED del modello.

Questo repository contiene **quattro firmware alternativi**, per due tipologie di modello (drift / switch) in due varianti ciascuno (classic / xenon):

| Firmware | Cartella | Uscite | Note |
|---|---|---|---|
| **Drift Classic** | [`/fw/2016_drift_classic`](fw/2016_drift_classic) | fari, coda, retro, scarico | fari anteriori bianco caldo |
| **Drift Xenon** | [`/fw/2016_drift_xenon`](fw/2016_drift_xenon) | fari, coda, retro, scarico | fari anteriori con effetto xenon (bianco freddo, accensione graduale) |
| **Switch Classic** | [`/fw/2016_switch_classic`](fw/2016_switch_classic) | fari (x2), coda (x2) | semplice ON/OFF in base al canale radio |
| **Switch Xenon** | [`/fw/2016_switch_xenon`](fw/2016_switch_xenon) | fari (x2), coda (x2) | come Switch Classic, con effetto xenon in accensione sui fari |

Non è disponibile un manuale ufficiale per nessuna delle quattro versioni: il funzionamento — comprese le procedure di calibrazione/programmazione — è descritto qui sotto sulla base dell'analisi diretta dei sorgenti firmware.

## 1. Il progetto

SEATURTLE ha un solo connettore di ingresso dalla ricevente e 4 uscite a due poli per il collegamento diretto dei LED. L'alimentazione richiesta è compresa tra 4,5V e 6,5V, prelevata direttamente dal modello; il manuale segnala che la scheda potrebbe non funzionare correttamente con l'elettronica di serie di alcuni modelli Tamiya.

Nelle versioni **Drift**, tramite l'adattatore fornito la centralina va collegata in parallelo al regolatore motore, in modo che il segnale di gas/freno arrivi sia all'ESC sia alla SEATURTLE. Nelle versioni **Switch**, l'ingresso va invece collegato a un canale libero della ricevente (tipicamente un canale ausiliario a 2 posizioni) usato semplicemente come interruttore per le luci.

## 2. Funzionamento del firmware

### Drift Classic / Drift Xenon

Il firmware (`SeaTurtle.c`) legge il canale gas/freno dell'ESC e gestisce quattro uscite: fari anteriori (`HEAD`), luci posteriori (`TAIL`), retromarcia (`REV`) ed effetto fiammata di scarico (`EXH`, con un pattern di lampeggio "backfire" predefinito).

**Calibrazione (`userSetup()`)**: all'accensione, dopo la sincronizzazione sul segnale PPM, il firmware controlla se il canale gas è tenuto fuori dalla zona centrale (sotto 1400µs o sopra 1600µs, cioè a fondo corsa in una direzione qualsiasi). In quel caso entra in modalità programmazione:

1. Tutte le uscite si accendono (`ALL_ON()`) a indicare che la centralina è in fase di apprendimento.
2. In base al lato verso cui il gas è tenuto premuto (avanti o indietro rispetto al centro), il firmware deduce se il canale è **invertito** (`PPM_reverse`) e insegue il valore di fondo scala finché il segnale continua ad allontanarsi dal centro.
3. Al rilascio del gas (ritorno in zona centrale), il firmware salva in EEPROM il valore di fondo scala (`EEPROM_PPMFULL`) e, dopo una nuova sincronizzazione, il valore di neutro (`EEPROM_PPMNEUTRAL`), marcando la scheda come collaudata (`EEPROM_TESTED`).
4. Da quel momento, a ogni accensione successiva, la centralina carica questi valori dall'EEPROM e li usa per determinare in tempo reale marcia avanti/frenata/retromarcia — senza bisogno di ripetere la calibrazione, a meno che non la si rifaccia volontariamente ripetendo la stessa procedura.

**Scheda "vergine" (`hardwareTest()`)**: se la scheda non è ancora mai stata calibrata (EEPROM di fabbrica, non ancora scritta), invece di funzionare normalmente il firmware entra in un semplice loop di test hardware, che accende una singola uscita alla volta in base alla posizione istantanea del canale letto (una soglia diversa per ciascuna delle 4 uscite HEAD/TAIL/REV/EXH), utile in produzione per verificare rapidamente che scheda e collegamenti funzionino, senza dover prima eseguire la calibrazione.

L'unica differenza tra le due varianti è l'effetto dei fari anteriori: **Classic** li accende semplicemente a piena luminosità (bianco caldo), mentre **Xenon** li accende con un effetto di accensione graduale a PWM (tipico delle lampade allo xeno, reso con luci bianco freddo).

### Switch Classic / Switch Xenon

Il firmware (`SeaTurtle.c`, versione switch) è molto più semplice: legge un singolo canale a 2 posizioni e si limita ad accendere (`HEAD1/HEAD2`, `TAIL1/TAIL2`) o spegnere tutti i LED in base alla posizione del canale, con una soglia fissa a 1500µs e una piccola isteresi anti-glitch. **Non usa l'EEPROM e non richiede alcuna calibrazione**: basta collegarla e usarla.

Anche qui l'unica differenza tra le due varianti è l'effetto dei fari: **Classic** li accende/spegne di netto, **Xenon** aggiunge lo stesso effetto di accensione graduale a PWM della versione Drift Xenon, applicato ai fari anteriori.

## 3. Compilatore

Tutti e quattro i firmware sono scritti per **mikroC PRO for PIC** di [MikroElektronika](https://www.mikroe.com/mikroc-pic), per lo stesso microcontrollore **PIC12F629** usato in Grizzly3 (datasheet in [`/ref`](ref/PIC12F629-675.pdf)), e rientrano tutti ampiamente nel limite di 2048 program word della licenza gratuita:

| Firmware | ROM usata | % sul totale |
|---|---|---|
| Drift Classic | 605 / 1024 word | 59% |
| Drift Xenon | 662 / 1024 word | 65% |
| Switch Classic | 159 / 1024 word | 16% |
| Switch Xenon | 222 / 1024 word | 22% |

Non è quindi necessaria alcuna licenza a pagamento per compilare o modificare questi firmware.

## 4. Programmazione della scheda

**Non è necessario mettere mano al codice sorgente.** Per programmare la scheda è sufficiente collegare il PIC12F629 a un programmatore compatibile, ad esempio un **PICkit 2/3/4**, e caricare il file `.hex` già compilato della versione desiderata (nella rispettiva cartella `/fw/2016_*`).

Il PCB espone 5 pad ICSP (`VPP`, `VDD`, `GND`, `PGD`, `PGC`), con la disposizione mostrata nello schema seguente:

<p align="center">
  <img src="assembling/icsp.png" alt="Piedinatura ICSP SEATURTLE" width="300">
</p>

Non sono richieste altre operazioni dopo il flashing, ma va tenuto presente il comportamento del firmware al primo avvio:
- nelle versioni **Drift**, appena flashata la scheda non è ancora calibrata: finché non si esegue almeno una volta la procedura di programmazione (tenere il gas a fondo, in avanti o indietro, all'accensione, e poi rilasciarlo — vedi punto 2), il firmware resta in un loop di test che si limita ad accendere un'uscita alla volta in base alla posizione del canale, utile per un rapido collaudo ma non rappresentativo del funzionamento normale;
- nelle versioni **Switch** non è prevista alcuna calibrazione: la scheda è già pronta all'uso non appena flashata.

## 5. Il PCB

Il circuito stampato è stato disegnato in **Eagle CAD** (file sorgente: [`/brd/seaturtle.brd`](brd/seaturtle.brd)).

Nella cartella [`/brd/gerber`](brd/gerber) sono presenti tutti i file Gerber (e uno `.zip` già pronto con l'intero pacchetto, `gerber_seaturtle.zip`) necessari per far produrre il PCB su un servizio di fabbricazione esterno, ad esempio [JLCPCB](https://jlcpcb.com/), [PCBWay](https://www.pcbway.com/) o simili: è sufficiente caricare l'archivio `.zip` (o i singoli file Gerber) nel loro configuratore online per ottenere un preventivo e ordinare le schede.

Nella cartella [`/assembling`](assembling) è presente la distinta componenti (`componenti.xls`), utile per l'assemblaggio della scheda (tutti componenti SMD in package 0805, PIC12F629-I/SN).

## Struttura del repository

```
seaturtle/
├── assembling/      # Distinta componenti e schema piedinatura ICSP
├── brd/             # Progetto Eagle CAD (.brd) e file Gerber
├── fw/
│   ├── 2016_drift_classic/    # Fari bianco caldo, calibrazione automatica
│   ├── 2016_drift_xenon/      # Come sopra, con effetto xenon sui fari
│   ├── 2016_switch_classic/   # Semplice ON/OFF via canale radio
│   └── 2016_switch_xenon/     # Come sopra, con effetto xenon sui fari
├── ref/             # Datasheet PIC12F629/675
├── seaturtle.jpg
└── seaturtle_logo.jpg
```

## Licenza

Questo progetto è distribuito con licenza **MIT** — vedi il file [LICENSE](LICENSE).
