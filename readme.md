# ![](./SRC/CLIENT_DATA/images/java_icon.png "Java 8") JAVA8 #

## ToC ##

* [Paketinfo](#paketinfo)
* [Paket erstellen](#paket_erstellen)
  * [Makefile und spec.json](#makefile_und_spec)
  * [pystache](#pystache)
  * [Verzeichnisstruktur](#verzeichnisstruktur)
  * [Makefile-Parameter](#makefile_parameter)
  * [spec.json](#spec_json)
* [Installation](#installation)
* [Allgemeines](#allgemeines)
  * [Properties](#properties)
  * [Aufbau des Paketes](#paketaufbau)
  * [Nomenklatur](#nomenklatur)
* [Lizenzen](#lizenzen)
  * [Dieses Paket](#licPaket)
  * [Oracle-Lizenzen](#licOracle)
  * [psDetail](#licPsDetail)
  * [GetRealName](#licGetRealName)
  * [7zip](#lic7zip)
  * [Logo](#logo)
* [Anmerkungen/ToDo](#anmerkungen_todo)



<div id="paketinfo"></div>

## Paketinfo ##

Dieses OPSI-Paket (bzw. dessen Quellen) fuer **Java 8** deckt optional sowohl 
die **Runtime Enivronment (JRE)** als auch das **Development Kit (JDK)** jeweils 
in der 32- und 64-Bit-Version ab.  
Weiterhin wird optional (nur beim JDK) die JDK-Dokumentation installiert.

Das Paket wurde aus dem internen Paket des *Max-Planck-Institut fuer Mikrostrukturphysik*
abgeleitet und fuer die Verwendung im *DFN*-Repository angepasst und erweitert.
Es wird versucht auf die Besonderheiten der jeweiligen Repositories einzugehen;
entsprechend werden durch ein einfaches ***Makefile*** aus den Quellen verschiedene
Pakete erstellt.

Teile dieser Dokumentation beziehen sich nicht ausschliesslich auf die erstellten 
OSPI-Pakete, sondern beruecksichtigen auch den Build-Prozess.



<div id="paket_erstellen"></div>

## Paket erstellen ##

Dieser Abschnitt beschaeftigt sich mit der Erstellung des OPSI-Paketes aus
dem Source-Paket und nicht mit dem OPSI-Paket selbst.



<div id="makefile_und_spec"></div>

### Makefile und spec.json ###

Da aus den Quellen verschiedene Versionen des Paketes mit entsprechenden Anpassungen
generiert werden sollen (intern, DFN; testing/release) wurde hierfuer ein
**<code>Makefile</code>** erstellt. Darueber hinaus steuert **<code>spec.json</code>** 
die Erstellung der Pakete.

Im Idealfall ist beim Erscheinen einer neuen Release von JRE bzw. JDK lediglich
**<code>spec.json</code>** anzupassen.



<div id="pystache"></div>

### pystache ###

Als Template-Engine kommt **<code>pystache</code>** zum Einsatz.
Das entsprechende Paket ist auf dem Build-System aus dem Repository der verwendeten
Distribution zu installieren.

Unter Debian/Ubuntu erledigt das:
> <code>sudo apt-get install python-pystache</code>



<div id="verzeichnisstruktur"></div>

### Verzeichnisstruktur ###

Die erstellten Pakete werden im Unterverzeichnis **<code>BUILD</code>** abgelegt.

Einige Files (control, postinst, setup.opsiscript) werden bei der Erstellung erst aus _<code>.in</code>_-Files
generiert, welche sich in den Verzeichnissen <code>SRC/OPSI</code> und <code>SRC/CLIENT_DATA</code> befinden.
Die <code>SRC</code>-Verzeichnisse sind in den OPSI-Paketen nicht mehr enthalten.



<div id="makefile_parameter"></div>

### Makefile-Parameter ###
OPSI erlaubt des Pakete im Format <code>cpio</code> und <code>tar</code> zu erstellen.  
Als Standard ist <code>cpio</code> festgelegt.  
Das Makefile erlaubt die Wahl des Formates ueber die Umgebungsvariable bzw. den Parameter:
> *<code>ARCHIVE_FORMAT=&lt;cpio|tar&gt;</code>*

Ueber einen weiteren Parameter laesst sich auch der Umfang des zu erstellenden 
Paketes festlegen:
> *<code>PACKAGE=[jre|jdk|full]</code>*

Ohne Angabe des Parameters bietet das erstellte OPSI-Paket die Installation 
von JRE und JDK an.

Das Paket kann mit *"batteries included"* erstellt werden. In dem Fall erfolgt 
der Download der Software beim Erstellen des OPSI-Paketes und nicht erst bei
dessen Installation:
> *<code>ALLINC=[true|false]</code>*

Standard ist hier die Erstellung des leichtgewichtigen Paketes (```ALLINC=false```).


<div id="spec_json"></div>

### spec.json ###

Haeufig beschraenkt sich die Aktualisierung eines Paketes auf das Aendern der 
Versionsnummern und des Datums etc. In einigen Faellen ist jedoch auch das Anpassen
weiterer Variablen erforderlich, die sich auf verschiedene Files verteilen.  
Auch das soll durch das Makefile vereinfacht werden. Die relevanten Variablen
sollen nur noch in <code>spec.json</code> angepasst werden. Den Rest uebernimmt *<code>make</code>*



<div id="installation"></div>

## Installation ##

Die Software selbst wird - sofern bei der Paketerstellung nicht anders vorgegeben - 
<u>nicht</u> mit diesem Paket vertrieben. Fuer die *"batteries included"*-Pakete 
entfaellt dieser Abschnitt.

Bei der Installation des Paketes im Depot erfolgt im <code>postinst</code>-Script 
der Download der Software vom Hersteller (Windows, 32 und 64 Bit).  
Ein manueller Download sollte dann nicht erforderlich sein. 

Das Gesamtvolumen der herunterzuladenden Dateien betraegt ca. **625 MByte**.



<div id="allgemeines"></div>

## Allgemeines ##


<div id="properties"></div>

### Properties ###

Je nach Art des erstellten Paketes und den Einstellungen in der <code>spec.json</code>
koennen die verfuegbaren Properties abweichen.

| Property | Type | Values | Default  | Multivalue | Editable | Description | Anmerkung |
|----------|:----:|--------|----------|:----------:|:--------:|-------------|------|
| jre_or_jdk | unicode | "JRE", "JDK" | "JRE" | False | False | Install only JRE or full JDK? (obsolete) | (obsolet, wird entfernt) |
| install_jre | bool |  | True/False |  |  | Install Java Runtime Environment | Default abhaengig vom erstellten Paket |
| install_jdk | bool |  | True/False |  |  | Install Java SE Developemnt Kit | Default abhaengig vom erstellten Paket |
| install_jdk_doc | bool |  | False |  |  | Install Java SE Development Kit Documentation (only available for JDK) | verfuegbar falls JDK enthalten |
| web_java | unicode | "Disable", "Enable" | "Disable" | False | False | Allow Java applets in web browser? |  |
| install_architecture | unicode | "32 bit", "64 bit", "both", "sysnative" | "sysnative" | False | False | which architecture (32/64 bit) should be installed |  |
| default_language | unicode | "de", "en-GB", "en-US" | "en-US" | False | False | application default language | fuer Java nicht relevant, inaktiv via spec.json | 
| custom_post_install | unicode | "none", "custom_test.opsiinc", "post-install.opsiinc" | "none" | False | True | Define filename for include script in custom directory after installation |  |
| custom_post_uninstall | unicode | "none", "custom_test.opsiinc", "post-uninstall.opsiinc" | "none" | False | True | Define filename for include script in custom directory after deinstallation |  |
| log_level | unicode | "default", "1", "2", "3", "4", "5", "6", "7", "8", "9" | "default" | False | False | Loglevel for this package |  |
| kill_running | bool |  | False |  |  | kill running instance (for software on_demand) | verfuegbar wenn in spec.json aktiviert |
| kill_applic | unicode |  |  | True | True | Instead of killing java only, kill also these running applications | verfuegbar wenn in spec.json aktiviert |



<div id="paketaufbau"></div>

### Aufbau des Paketes ###

* **<code>variables.opsiinc</code>** - Da Variablen ueber die Scripte hinweg mehrfach
verwendet werden, werden diese (bis auf wenige Ausnahmen) zusammengefasst hier deklariert.
* **<code>product_variables.opsiinc</code>** - die producktspezifischen Variablen werden
hier definiert
* **<code>setup.opsiscript </code>** - Das Script fuer die Installation.
* **<code>uninstall.opsiscript</code>** - Das Uninstall-Script
* **<code>delsub.opsiinc</code>**- Wird von Setup und Uninstall gemeinsam verwendet.
Vor jeder Installation/jedem Update wird eine alte Version entfernt. (Ein explizites
Update-Script existiert derzeit nicht.)
* **<code>checkinstance.opsiinc</code>** - Pruefung, ob eine Instanz der Software laeuft.
Gegebenenfalls wird das Setup abgebrochen. Optional kann eine laufende Instanz 
zwangsweise beendet werden.
* **<code>checkvars.sh</code>** - Hilfsscript fuer die Entwicklung zur Ueberpruefung,
ob alle verwendeten Variablen deklariert sind bzw. nicht verwendete Variablen
aufzuspueren.
* **<code>bin/</code>** - Hilfprogramme; hier: **7zip**, **psdetail**
* **<code>images/</code>** - Programmbilder fuer OPSI



<div id="nomenklatur"></div>

### Nomenklatur ###

Praefixes in der Produkt-Id definieren die Art des Paketes:

* **0_** oder **test_** - Es handelt sich um ein Test-Paket. Beim Uebergang zur Produktions-Release
wird der Praefix entfernt.
* **dfn_** - Das Paket ist zur Verwendung im DFN-Repository vorgesehen.

Die Reihenfolge der Praefixes ist relevant; die Markierung als Testpaket ist 
stets fuehrend.



<div id="lizenzen"></div>

## Lizenzen ##


<div id="licPaket"></div>

###  Dieses Paket ###

Dieses OPSI-Paket steht unter der *GNU General Public License* **GPLv3**.

Ausgenommen von dieser Lizenz sind die unter **<code>bin/</code>** zu findenden
Hilfsprogramme. Diese unterliegen ihren jeweiligen Lizenzen.



<div id="licOracle"></div>

### Oracle-Lizenzen ###

Oracle fordert vor dem Download der Pakete ein, den jeweiligen Lizenzbestimmungen
zuzustimmen.

* JDK/JRE:
> You must accept the [Oracle Binary Code License Agreement for Java SE](http://www.oracle.com/technetwork/java/javase/terms/license/index.html) to download this software.

* JDK Dokumentation:
> You must accept the [Java SE Development Kit 8 Documentation License Agreement](http://www.oracle.com/technetwork/java/javase/overview/javase8speclicense-2158700.html) to download this software.

* JavaFX API Documentation:
> You must accept the [Oracle Legal Notices](http://docs.oracle.com/javase/7/docs/legal/cpyr.html) to download this software.

* Demos/Samples:
> You must accept the [Oracle BSD License](http://www.oracle.com/technetwork/java/javase/terms/license/oraclebsd-1603217.txt). to download this software.

Die Installation dieses Paketes setzt voraus, dass der Nutzer dem Folge geleistet
hat. Sollte den Lizenzbedingungen nicht zugestimmt werden, darf dieses Paket nicht
verwendet werden.



<div id="licPsDetail"></div>

### psDetail ###
**Autor** der Software: Jens Boettge <<boettge@mpi-halle.mpg.de>> 

Die Software **psdetail.exe**  wird als Freeware kostenlos angeboten und darf fuer 
nichtkommerzielle sowie kommerzielle Zwecke genutzt werden. Die Software
darf nicht veraendert werden; es duerfen keine abgeleiteten Versionen daraus 
erstellt werden.

Es ist erlaubt Kopien der Software herzustellen und weiterzugeben, solange 
Vervielfaeltigung und Weitergabe nicht auf Gewinnerwirtschaftung oder Spendensammlung
abzielt.

Haftungsausschluss:  
Der Auto lehnt ausdruecklich jede Haftung fuer eventuell durch die Nutzung 
der Software entstandene Schaeden ab.  
Es werden keine ex- oder impliziten Zusagen gemacht oder Garantien bezueglich
der Eigenschaften, des Funktionsumfanges oder Fehlerfreiheit gegeben.  
Alle Risiken des Softwareeinsatzes liegen beim Nutzer.

Der Autor behaelt sich eine Anpassung bzw. weitere Ausformulierung der Lizenzbedingungen
vor.

Fuer die Nutzung wird das *.NET Framework ab v3.5*  benoetigt.



<div id="licGetRealName"></div>

### GetRealName ###
**Autor** der Software: Jens Boettge <<boettge@mpi-halle.mpg.de>> 

Die Software **GetRealName.exe**  wird als Freeware kostenlos angeboten und darf fuer 
nichtkommerzielle sowie kommerzielle Zwecke genutzt werden. Die Software
darf nicht veraendert werden; es duerfen keine abgeleiteten Versionen daraus 
erstellt werden.

Es ist erlaubt Kopien der Software herzustellen und weiterzugeben, solange 
Vervielfaeltigung und Weitergabe nicht auf Gewinnerwirtschaftung oder Spendensammlung
abzielt.

Haftungsausschluss:  
Der Auto lehnt ausdruecklich jede Haftung fuer eventuell durch die Nutzung 
der Software entstandene Schaeden ab.  
Es werden keine ex- oder impliziten Zusagen gemacht oder Garantien bezueglich
der Eigenschaften, des Funktionsumfanges oder Fehlerfreiheit gegeben.  
Alle Risiken des Softwareeinsatzes liegen beim Nutzer.

Der Autor behaelt sich eine Anpassung bzw. weitere Ausformulierung der Lizenzbedingungen
vor.



<div id="lic7zip"></div>

### 7zip ###
Es gilt die Lizenz von http://www.7-zip.org/license.txt.



<div id="logo"></div>

### Logo ###
Anregung fuer das erstellte Logo war https://pixabay.com/de/java-pokal-kaffee-programmierung-151343.  
Die Variationen des Icon-Satzes fuer das OPSI-Paket wurden von mir unter Verwendung
weiterer freier Grafiken erstellt.



<div id="anmerkungen_todo"></div>

## Anmerkungen/ToDo ##

Es fehlt noch:

* Installation von jdk-*-docs-all.zip
* weitere Features und Einstellungen...

-----
Jens Boettge <<boettge@mpi-halle.mpg.de>>, 2017-11-24 16:52:51 +0100
