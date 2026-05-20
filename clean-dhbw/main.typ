#import "@preview/clean-dhbw:0.4.0": *
#import "glossary.typ": glossary-entries

#let clr-header = rgb("#1a1a2e")
#let clr-row-odd = rgb("#f5f5f5")
#let clr-row-even = white
#let clr-high = rgb("#fde8e8")
#let clr-mid = rgb("#fef9e7")
#let clr-low = rgb("#eafaf1")
#let clr-none = white

#show: clean-dhbw.with(
  title: "Softwarequalität",
  authors: (
    (name: "Etienne Luke Josef Bader", student-id: "9578543", course: "TINF23B2", course-of-studies: "Informatik"),
  ),
  city: "Karlsruhe",
  type-of-thesis: "Hausarbeit",
  at-university: true,
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries,
  language: "de",
  supervisor: (university: "Dennis Kube, Jonathan Schwarzenböck"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Karlsruhe",
  university-short: "DHBW",
)

= Einleitung

== Projektbeschreibung

Das Sportwettbewerbs-Managementtool ist eine im Rahmen der Vorlesung Advanced Software Engineering an der Dualen Hochschule Baden-Württemberg Karlsruhe entwickelte Anwendung. Sie unterstützt Organisatorinnen und Organisatoren bei der Planung und Durchführung von Sportwettbewerben und bietet Funktionen zur Verwaltung von verschiedenen Arten von Personen, Teams, Wettkämpfen, Spielplänen, Lageplänen und Tickets. Das System besteht aus einem Java-Backend auf Basis des Spring-Boot-Frameworks sowie einem React-Frontend und wird über eine REST-API angesteuert. Die Persistenz läuft dateibasiert.

Ein zentrales Merkmal des Projekts ist die bewusste Vorgabe, Clean Architecture sowie @DDD zu verwenden. Die Clean Architecture gliedert das System in vier klar voneinander getrennte Schichten: Domain, Application, Adapter und Plugins. Ziel dieser Architektur ist es, die fachliche Kernlogik von technischen Details wie Frameworks oder Persistenzmechanismen zu entkoppeln und langfristige Wartbarkeit und Erweiterbarkeit sicherzustellen.

== Ziel der Arbeit

Im Mittelpunkt dieser Hausarbeit steht die Frage, inwieweit die gewählte Architektur im Sinne des Softwarequalitätsmanagements tatsächlich konsequent umgesetzt wurde. Als Bewertungsmaßstab dienen zwei Teilmerkmale des Qualitätsmerkmals Maintainability aus dem internationalen Standard @ISO:short 25010: Modularity und Modifiability. Modularity beschreibt, in welchem Maße ein System aus unabhängigen Komponenten besteht, sodass Änderungen an einer Komponente möglichst geringe Auswirkungen auf andere haben. Modifiability hingegen beschreibt, wie effektiv das System verändert werden kann, ohne dabei unbeabsichtigte Seiteneffekte in anderen Teilen der Anwendung zu erzeugen.

Beide Teilmerkmale sind unmittelbar mit dem Anspruch der Clean Architecture verknüpft und eignen sich daher als konkreter, messbarer Maßstab zur Bewertung ihrer Umsetzung. Die Analyse konzentriert sich auf den `CompetitionController` als repräsentatives Fallbeispiel, an dem sich eine systematische Analyse der vorgebenen Architektur besonders gut eignet. Daraus werden anschließend begründete Optimierungsmaßnahmen abgeleitet.

= Grundlagen

== Clean Architecture

=== Motivation und Ziel

Moderne Softwaresysteme unterliegen einem ständigen Wandel. Technologien, Frameworks und Abhängigkeiten veralten, werden ersetzt oder weiterentwickelt — häufig innerhalb weniger Jahre @briem[S.~2]. Eine Architektur, die eng an konkrete Technologien geknüpft ist, altert zwangsläufig mit diesen zusammen und erschwert spätere Anpassungen erheblich.

Die Clean Architecture begegnet diesem Problem durch eine klare strukturelle Trennung von langlebigem und kurzlebigem Code. Ihr zentrales Ziel ist es, einen technologieunabhängigen Kern zu schaffen und alle technischen Details, wie Datenbanken, Frameworks oder Benutzeroberflächen, als austauschbare Randkomponenten zu behandeln @briem[S.~9]. Das angestrebte Ergebnis ist ein System, in dem Technologieentscheidungen spät getroffen oder nachträglich revidiert werden können, ohne den Anwendungskern zu berühren @briem[S.~8]. Robert C. Martin fasst dies so zusammen: Eine gute Architektur maximiert die Anzahl der Entscheidungen, die noch nicht getroffen werden müssen @martin[S.~141].

=== Die Dependency Rule

Das zentrale Prinzip der Clean Architecture ist die Dependency Rule. Sie besagt, dass Abhängigkeiten zwischen Systemteilen ausschließlich von außen nach innen zeigen dürfen @briem[S.~11]. Dabei sind Abhängigkeitspfeile (Compile-Time Dependencies), die zeigen welchen Code eine Klasse direkt referenziert, von Aufrufpfeilen (Runtime Dependencies) zu unterscheiden. Aufrufpfeile können in beide Richtungen verlaufen @briem[S.~12].

Die Dependency Rule betrifft daher ausschließlich die Abhängigkeitspfeile. Innere Schichten dürfen äußere Schichten weder kennen noch referenzieren. Eine Verletzung dieser Regel missachtet die vorgesehen Architektur, da Änderungen an der äußeren Schicht dann unmittelbar Auswirkungen auf den eigentlich stabilen Kern haben @martin[S.~203].

=== Schichtenaufbau

Die Clean Architecture gliedert ein System typischerweise in vier Schichten @briem[S.~14]:

Die *Domain-Schicht* bildet den innersten Kern mit den zentralen Geschäftsobjekten und organisationsweit gültigen Geschäftsregeln @briem[S.~18--19]. Sie ist vollständig unberührt von Änderungen an Infrastrukturdetails wie der @GUI, dem Daten-Transport oder der Persistenz @briem[S.~18].

Die *Application-Schicht* enthält die anwendungsspezifischen Anwendungsfälle (Use Cases) und implementiert Regeln, die nur für den konkreten Anwendungsfall gelten @briem[S.~23--24]. Sie ist ebenso isoliert von Änderungen an der Persistenz oder der @GUI @briem[S.~25].

Die *Adapter-Schicht* vermittelt zwischen Anwendungslogik und Außenwelt durch Formatkonvertierungen @briem[S.~30]. Ihr Ziel ist die vollständige Entkopplung von innen und außen. Dadurch wird ermöglicht, dass beispielsweise kein @SQL:short\-Code in der Anwendung selbst oder keine Renderlogik der @GUI im Kern vorhanden ist @briem[S.~31].

Die *Plugin-Schicht* ist die äußerste Schicht mit Frameworks, Persistenz, Web und @GUI @briem[S.~37]. Sie soll ausschließlich Delegationscode enthalten und darf keine Anwendungslogik enthalten. Alle Entscheidungen sollen bereits in den inneren Schichten gefallen sein @briem[S.~37--38]. Während Domain-Code Jahrzehnte Bestand haben soll, veralten Plugin-Code und Frameworks mitunter innerhalb von Wochen bis Monaten @briem[S.~50].

=== Innere Schichten definieren Interfaces

Ein wesentliches Umsetzungsmittel der Dependency Rule ist die konsequente Nutzung von Interfaces. Innere Schichten definieren Schnittstellen, äußere Schichten implementieren diese @briem[S.~16]. So kann die Domain-Schicht ein `Repository`-Interface definieren, ohne zu wissen, ob die konkrete Implementierung eine Datei, eine relationale Datenbank oder einen Webservice verwendet. Dieses als Dependency Inversion Principle bekannte Muster ist einer der zentralen Aspekte der Clean Architecture @martin[S.~91].

== Softwarequalität nach ISO/IEC 25010

@ISO 25010 ist der internationale Standard zur Beschreibung und Bewertung von Softwarequalität. Er definiert ein hierarchisches Qualitätsmodell, das Qualitätsmerkmale in Hauptmerkmale und Teilmerkmale untergliedert @iso25010[Abschn.~4.2]. Als Bewertungsmaßstab für diese Arbeit sind zwei Teilmerkmale des Hauptmerkmals *Maintainability* (Wartbarkeit) relevant.

*Modularity* beschreibt den Grad, zu dem ein System aus voneinander unabhängigen Komponenten besteht, sodass eine Änderung an einer Komponente möglichst geringe Auswirkungen auf andere Komponenten hat @iso25010[Abschn.~4.2.7.1].

*Modifiability* beschreibt den Grad, zu dem ein System effektiv und effizient verändert werden kann, ohne dabei unbeabsichtigte Seiteneffekte in anderen Teilen der Anwendung zu erzeugen @iso25010[Abschn.~4.2.7.3]. Ein System mit schlechter Modularität erschwert gezielte Modifikationen, da Änderungen unkontrolliert ausstrahlen können.

Beide Teilmerkmale sind unmittelbar mit dem Anspruch der Clean Architecture verknüpft: Die Dependency Rule und die daraus resultierende Schichtentrennung sind präzise darauf ausgelegt, Modularity und Modifiability zu maximieren. Die Clean Architecture liefert damit nicht nur ein Designprinzip, sondern zugleich den Maßstab, an dem ihre Umsetzung gemessen werden kann.

= Betrachtung des Projekts

Dieses Kapitel beschreibt den Gesamtaufbau des Sportwettbewerbs-Managementtools in Bezug auf seine Architektur und arbeitet sowohl gelungene Aspekte als auch strukturelle Abweichungen heraus, die als Grundlage für die Analyse in Kapitel 4 dienen.

== Architekturaufbau des Projekts

Das Backend des Projekts ist als Maven-Multi-Modul-Projekt organisiert und folgt dem in Kapitel 2 beschriebenen Schichtenmodell. Die vier Module sind entsprechend ihrer Schicht benannt: `3_domain`, `2_application`, `1_adapter` und `0_plugins`. Die Plugins wiederum sind wieder in weitere Module unterteilt, sodass diese einfach ausgetauscht werden können. Diese Nummerierung spiegelt die Abhängigkeitsrichtung wider und entspricht der Empfehlung des @ASE\-Dozenten Lars Briem, Schichten als separate Projekte umzusetzen, sodass der Compiler unzulässige Abhängigkeiten verhindert @briem[S.~44].

Die *Domain-Schicht* (`3_domain`) enthält die zentralen Geschäftsobjekte `Competition`, `Match`, `Standings`, `Team`, `Person` und ihre Subtypen, `Ticket` sowie `Siteplan`. Zu jedem Aggregat existiert ein Repository-Interface in der Domain-Schicht. Die Domain-Schicht enthält keinerlei Framework-Imports, was der Grundregel der Clean Architecture entspricht @briem[S.~16].

Die *Application-Schicht* (`2_application`) enthält für jeden fachlichen Bereich einen Service sowie die zugehörigen UseCase-Interfaces, darunter beispielsweise `CreateCompetitionUseCase` und `GetStandingsUseCase`. Alle UseCases kommunizieren ausschließlich über Command-Objekte und @DTO:pl mit den äußeren Schichten.

Die *Adapter-Schicht* (`1_adapter`) enthält Mapper-Klassen, die zwischen Domain-Objekten und Persistenz-@DTO:pl übersetzen. Diese Schicht hat keine Kenntnis von @HTTP:short, @REST:short oder Spring.

Die *Plugin-Schicht* (`0_plugins`) gliedert sich in `plugin_rest` mit den @REST\-Controllern und `plugin_io` mit der dateibasierten Persistenz. Letztere implementiert jeweils die in der Domain-Schicht definierten Repository-Interfaces und erfüllen damit das Dependency-Inversion-Prinzip @briem[S.~16].

== Korrekte Umsetzung im Überblick

In weiten Teilen des Projekts ist die Clean Architecture konsequent umgesetzt. Der `PersonController` nutzt für alle vier Schreiboperationen ausschließlich UseCase-Interfaces ohne direkten Repository-Zugriff. Gleiches gilt für den `TicketController`, dessen beide schreibenden Endpunkte vollständig über `CreateTicketUseCase` und `SellTicketUseCase` abgewickelt werden @briem[S.~37]. Auch die Domain-Schicht zeigt qualitativ hochwertige Umsetzungsbeispiele: Die Klasse `SportResultComparator` nutzt das Strategy-Pattern über das Interface `ScoringStrategy`, sodass neue Sportarten hinzugefügt werden können, ohne bestehenden Code zu verändern.

== Strukturelle Abweichungen

Neben diesen gelungenen Aspekten finden sich im Projekt zwei strukturelle Abweichungen von der Clean Architecture, die für die Bewertung nach @ISO 25010 relevant sind.

=== Direkter Repository-Zugriff in der Plugin-Schicht

Der `CompetitionController` hält als Instanzvariable nicht nur die UseCase-Interfaces `CreateCompetitionUseCase` und `GetStandingsUseCase`, sondern zusätzlich eine direkte Referenz auf `CompetitionRepository`. Von den sieben Endpunkten des Controllers umgehen fünf die Application-Schicht vollständig:

- `GET /getById`: 
  - Holt die Wettbewerbs-Instanz über ihre ID
  - → `competitionRepository.findCompetitionById(id)`

- `GET /getMatchesByCompetitionId`
  - Holt alle Partien, welche während eines Wettbewerbs durchgeführt werden
  - → `competitionRepository.getAllMatchesFromCompetitionId(id)`

- `GET /getMatchById`
  - Holt eine Partie-Instanz über ihre ID
  - → `competitionRepository.findMatchById(id)`

- `GET /getCompetitionByCompetitionName`
  - Holt den Wettbewerb basierend auf dessen Namen
  - → `competitionRepository.getCompetitionByName(name)`

- `POST /registerMatchResults`
  - Speichert/Registriert Ergebnisse zu einer Partie
  - → `competitionRepository.registerResultsForMatchByID(...)`

Lediglich `GET /getStandingsFromCompetition` und `POST /create` nutzen den vorgesehenen Weg über UseCase-Interfaces. Die Plugin-Schicht greift damit für den Großteil ihrer Operationen direkt auf die Domain-Schicht zu, was eine Verletzung der Dependency Rule darstellt @briem[S.~37]. Das Muster findet sich auch im `PersonController` und `TicketController` (je ein Lesezugriff), ist jedoch im `CompetitionController` am deutlichsten.

=== Framework-Abhängigkeit in der Application-Schicht

Die `pom.xml` der Application-Schicht deklariert `spring-boot-starter-web` als Compile-Zeit-Abhängigkeit. Dies hat zur Folge, dass alle fünf Service-Klassen die Spring-Annotation `@Service` tragen. Frameworks sind jedoch Details, die als Plugins an den Rand der Anwendung (Plugin Layer) gehören. Dadurch zeigen Abhängigkeiten vom Anwendungscode in das Framework, also in die falsche Richtung @briem[S.~58--59]. Die Application-Schicht kann damit nicht mehr unabhängig von Spring kompiliert oder getestet werden, was einem der Grundziele der Clean Architecture widerspricht @briem[S.~16].

= Analyse und Bewertung

Dieses Kapitel bewertet die in Kapitel 3 beschriebenen Abweichungen anhand der eingeführten Kriterien und quantifiziert den Handlungsbedarf mittels FMEA.

== Bewertung: Direkter Repository-Zugriff

=== Fehlende Kapselung der Anwendungslogik

Die Application-Schicht dient nicht allein als Durchleitungsebene, sondern als zentraler Ort für anwendungsspezifische Geschäftslogik @briem[S.~23]. Dies zeigt sich deutlich am Vergleich mit den Endpunkten, die den vorgesehenen Weg nutzen: Der Aufruf von `createCompetitionUseCase.create(command)` löst in `CompetitionService` eine Kette fachlicher Schritte aus — Auflösung der Team- und Official-IDs, automatische Spielplanerstellung mittels `competition.scheduleMatches()` sowie Persistierung. Beim direkten Repository-Zugriff ist diese Logik entweder im Controller dupliziert oder schlicht nicht vorhanden. Das Plugin enthält damit Anwendungslogik — genau das, was Briem als grundlegenden Verstoß gegen die Rolle der Plugin-Schicht beschreibt @briem[S.~37--38].

=== Auswirkung auf Modularity

Im vorliegenden Fall hängt der `CompetitionController` durch den direkten Import von `CompetitionRepository` und mehreren Domain-Klassen (`Competition`, `Match`, `Standings`) unmittelbar von der Domain-Schicht ab. Plugin- und Domain-Schicht sind damit direkt aneinander gekoppelt, obwohl die Application-Schicht als Entkopplungsebene vorgesehen ist. Eine Änderung an der Signatur einer Repository-Methode würde damit nicht nur die Application-Schicht betreffen, sondern unmittelbar auch den Controller — ein direkter Verstoß gegen das Ziel der Modularity @iso25010[Abschn.~4.2.7.1]. Im Vergleich dazu hätte eine Änderung an `PersonRepository` keine direkte Auswirkung auf den `PersonController`, da dieser das Repository nicht kennt.

=== Auswirkung auf Modifiability

Soll künftig beim Abrufen eines Wettkampfs eine Berechtigungsprüfung oder Logging-Funktion eingebaut werden, müsste dies direkt im Controller implementiert werden. In einem System mit konsequenter Clean Architecture wäre dieser Eingriff auf die Application-Schicht beschränkt; der Controller bliebe unverändert. Zusätzlich besteht eine Inkonsistenz innerhalb des `CompetitionController` selbst: Zwei Endpunkte laufen korrekt über UseCase-Interfaces, fünf nicht. Diese Inkonsistenz erhöht die kognitive Last bei Weiterentwicklungen erheblich und widerspricht dem Grundsatz, dass die Plugin-Schicht ausschließlich Delegationscode enthalten soll @briem[S.~37].

== Bewertung: Framework-Abhängigkeit in der Application-Schicht

Die Application-Schicht deklariert `spring-boot-starter-web` in ihrer `pom.xml` als Compile-Zeit-Abhängigkeit. Damit kennt und benötigt die Application-Schicht Spring, um kompiliert werden zu können — eine strukturelle Verletzung der Dependency Rule, wonach Abhängigkeiten von außen nach innen zeigen sollen @briem[S.~11]. Die praktische Konsequenz ist, dass die Application-Schicht nicht mehr unabhängig von Spring gebaut oder betrieben werden kann @briem[S.~16]. Hinsichtlich Modularity würde ein Wechsel des Web-Frameworks nun auch die Application-Schicht berühren, obwohl er laut Clean Architecture ausschließlich die Plugin-Schicht betreffen sollte. Hinsichtlich Modifiability erfordern Komponententests der Services Spring-Kontext oder Spring-Mocking-Infrastruktur, obwohl die fachliche Logik von Spring vollständig unabhängig sein sollte @iso25010[Abschn.~4.2.7.3].

== Risikobewertung mittels FMEA

Um die identifizierten Befunde strukturiert zu priorisieren, wird eine Fehler-Möglichkeits- und Einfluss-Analyse (FMEA) durchgeführt @kube[S.~10]. Jede Fehlerquelle wird anhand dreier Faktoren bewertet:

- *A* — Auftrittswahrscheinlichkeit (1–10)
- *B* — Bedeutung der Fehlerfolge (1–10)
- *E* — Entdeckungswahrscheinlichkeit (1 = zwangsläufig entdeckt, 10 = kaum entdeckbar)

Die Risikoprioritätszahl ergibt sich als $"RPZ" = A times B times E$. Werte ab 100 gelten als hohes Risiko mit dringendem Handlungsbedarf @kube[S.~10].

#figure(
  table(
    columns: (2.5em, 1fr, 2em, 2em, 2em, 3em),
    align: (center, left, center, center, center, center),
    inset: (x: 8pt, y: 6pt),
    stroke: none,
    fill: (col, row) => if row == 0 { clr-header } else if calc.odd(row) { clr-row-odd } else { clr-row-even },
    table.cell(text(fill: white, weight: "bold")[ID]),
    table.cell(text(fill: white, weight: "bold")[Fehlerquelle]),
    table.cell(text(fill: white, weight: "bold")[A]),
    table.cell(text(fill: white, weight: "bold")[B]),
    table.cell(text(fill: white, weight: "bold")[E]),
    table.cell(text(fill: white, weight: "bold")[RPZ]),
    table.cell(align: center)[F1],
    [Direkter Repository-Zugriff im `CompetitionController` \ (5 von 7 Endpunkten umgehen die Application-Schicht)],
    [10], [7], [8],
    table.cell(fill: clr-high)[*560*],
    table.cell(align: center)[F2],
    [Spring-Compile-Abhängigkeit in der Application-Schicht \ (`spring-boot-starter-web` in `pom.xml`)],
    [10], [5], [4],
    table.cell(fill: clr-high)[*200*],
  ),
  caption: [FMEA-Analyse der identifizierten Architekturverletzungen],
) <fmea>

#figure(
  table(
    columns: (5em, 4em, 5em, 1fr),
    align: (center, center, left, left),
    inset: (x: 8pt, y: 6pt),
    stroke: none,
    fill: (col, row) => if row == 0 { clr-header } else if row == 1 { clr-none } else if row == 2 { clr-low } else if row == 3 { clr-mid } else { clr-high },
    table.cell(text(fill: white, weight: "bold")[RPZ]),
    table.cell(text(fill: white, weight: "bold")[Risiko]),
    table.cell(text(fill: white, weight: "bold")[Handlungsbedarf]),
    table.cell(text(fill: white, weight: "bold")[Maßnahmen]),
    [$"RPZ" = 1$],  [keins],  [keiner],          [keine],
    [$2 – 50$],     [gering], [nicht zwingend],  [können formuliert und umgesetzt werden],
    [$50 – 100$],   [mittel], [besteht],         [sollten formuliert und umgesetzt werden],
    [$100 – 1000$], [*hoch*], [*dringend*],      [müssen formuliert und umgesetzt werden],
  ),
  caption: [RPZ-Wertebereiche und Fehlerrisikoklassen (nach @kube[S.~10])],
) <rpz>

Beide Fehlerquellen fallen in die Risikoklasse *hoch*. F1 erhält A = 10, da die Verletzung bereits vollständig im Code vorhanden ist. B = 7 spiegelt die substanzielle Beeinträchtigung beider Qualitätskriterien wider. E = 8, da die Verletzung im normalen Entwicklungsbetrieb kaum auffällt — der Code kompiliert fehlerfrei und funktionale Tests würden keine Abweichung zeigen. F2 erhält A = 10 und B = 5, da die funktionalen Auswirkungen begrenzter sind; E = 4, da die Abhängigkeit in der `pom.xml` explizit sichtbar ist.

== Gesamtbewertung

Beide Befunde sind Ausdruck desselben Grundproblems: Die Dependency Rule wurde an der Grenze zwischen Plugin-Schicht und Application-Schicht nicht konsequent eingehalten. Im Kern — Domain- und Adapter-Schicht — ist die Architektur vorbildlich umgesetzt. An der äußersten Grenze entstehen jedoch Kurzschlussverbindungen, die Modularity und Modifiability untergraben. Die FMEA-Analyse bestätigt diesen Befund quantitativ und stuft beide Fehlerquellen als dringend ein @kube[S.~10]. F1 ist dabei als dringlicher zu bewerten, da seine Auswirkungen breiter und schwerer zu kontrollieren sind.

= Optimierungsmaßnahmen

Ausgehend von der FMEA werden konkrete Maßnahmen erarbeitet, geordnet nach RPZ. Die Umsetzung folgt dem PDCA-Kreislauf als iterativem Qualitätsverbesserungsprozess @kube[S.~5].

== Maßnahme 1: UseCase-Interfaces für alle Controller-Endpunkte (F1)

=== Beschreibung

Für jeden Endpunkt des `CompetitionController`, der derzeit direkt auf `CompetitionRepository` zugreift, wird ein eigenes UseCase-Interface eingeführt:

- `GET /getById` → `GetCompetitionByIdUseCase`
- `GET /getMatchesByCompetitionId` → `GetMatchesByCompetitionUseCase`
- `GET /getMatchById` → `GetMatchByIdUseCase`
- `GET /getCompetitionByCompetitionName` → `GetCompetitionByNameUseCase`
- `POST /registerMatchResults` → `RegisterMatchResultsUseCase`

Der `CompetitionController` wird so umgebaut, dass er ausschließlich UseCase-Interfaces als Abhängigkeiten hält. Alle Domain-Imports werden entfernt; der Controller kommuniziert nur noch über Command-Objekte und DTOs — analog zur bereits korrekten Umsetzung im `PersonController`.

=== Umsetzung im PDCA

*Plan:* Die neuen UseCase-Interfaces werden spezifiziert. Jedes Interface erhält genau eine Methode, die ein Command-Objekt entgegennimmt und ein DTO zurückgibt.

*Do:* Die Interfaces werden in der Application-Schicht angelegt, `CompetitionService` implementiert sie, und der `CompetitionController` wird umgestellt.

*Check:* Der `CompetitionController` darf keine `import`-Anweisungen aus `de.dhbw.ase.domain` mehr enthalten. Dies lässt sich automatisiert durch ArchUnit in der CI-Pipeline prüfen.

*Act:* Das gleiche Muster wird auf `PersonController` und `TicketController` übertragen, sodass alle Controller einheitlich nur über UseCase-Interfaces kommunizieren.

=== Erwartete Auswirkung

Plugin-Schicht und Domain-Schicht werden vollständig entkoppelt. Die Compile-Time-Abhängigkeiten des `CompetitionController` reduzieren sich von zwei Schichten auf eine. Fachliche Erweiterungen erhalten einen definierten Ort in der Application-Schicht, und alle sieben Endpunkte folgen demselben konsistenten Muster.

== Maßnahme 2: Spring-Abhängigkeit aus der Application-Schicht entfernen (F2)

=== Beschreibung

`spring-boot-starter-web` wird aus der `pom.xml` der Application-Schicht entfernt. Die `@Service`-Annotierungen aller fünf Service-Klassen werden durch eine `@Configuration`-Klasse in der Plugin-Schicht ersetzt, die die Services explizit als `@Bean` registriert.

=== Umsetzung im PDCA

*Plan:* Eine neue Klasse `ApplicationConfig` wird in `plugin_rest` angelegt. Da die Services Abhängigkeiten bereits per Konstruktor-Injektion erhalten, sind keine weiteren Anpassungen an den Service-Klassen erforderlich.

*Do:* Die `@Service`-Annotierungen werden aus allen Services entfernt, `spring-boot-starter-web` wird aus der `pom.xml` gestrichen, und `ApplicationConfig` übernimmt die Bean-Registrierung.

*Check:* `mvn compile -pl 2_application` muss ohne Fehler durchlaufen. Bestehende Unit-Tests bleiben unverändert lauffähig, da sie mit Mockito arbeiten und keinen Spring-Kontext benötigen.

*Act:* Zukünftige Services werden von Beginn an ohne Framework-Annotierungen entwickelt.

=== Erwartete Auswirkung

Die Application-Schicht wird vollständig framework-agnostisch. Ein Wechsel des Web-Frameworks betrifft ausschließlich die Plugin-Schicht — dies entspricht dem Ziel der Clean Architecture, Technologien als austauschbare Randkomponenten zu behandeln @briem[S.~52--53].

== Zusammenfassung der erwarteten Verbesserungen

Nach Einführung von ArchUnit-Tests sinkt E für F1 von 8 auf 2; die RPZ reduziert sich von 560 auf 140. Nach Entfernung der Spring-Abhängigkeit sinkt B für F2 von 5 auf 2; die RPZ reduziert sich von 200 auf 80, was der Risikoklasse „mittel" entspricht. Beide Maßnahmen zusammen führen zu einem System, das die Grundregeln der Clean Architecture konsequent einhält: Innere Schichten definieren Interfaces, äußere implementieren diese, und jede Schicht ist unabhängig kompilierbar und testbar @briem[S.~16].

= Fazit

Diese Arbeit hat das Sportwettbewerbs-Managementtool anhand der Teilmerkmale Modularity und Modifiability des ISO/IEC-25010-Standards untersucht und dabei die Clean Architecture als konkreten Bewertungsmaßstab herangezogen.

Die Analyse zeigt ein zweigeteiltes Bild. Im Kern — der Domain- und Adapter-Schicht — ist die Clean Architecture vorbildlich umgesetzt. An der Schichtgrenze zwischen Plugin- und Application-Schicht finden sich zwei strukturelle Abweichungen: Der `CompetitionController` umgeht die Application-Schicht für fünf von sieben Endpunkten durch direkten Repository-Zugriff, und die Application-Schicht hält eine Compile-Zeit-Abhängigkeit auf Spring Boot. Beide Befunde wurden mittels FMEA als hohes Risiko eingestuft (RPZ 560 und 200) und beeinträchtigen nachweislich Modularity und Modifiability.

Die erarbeiteten Optimierungsmaßnahmen — Einführung fehlender UseCase-Interfaces und Verlagerung der Spring-Konfiguration in die Plugin-Schicht — sind gezielt und mit überschaubarem Aufwand umsetzbar. Durch automatisierte Architekturprüfung mittels ArchUnit schaffen sie zudem eine nachhaltige Absicherung gegen künftige Regressionen.

Das Fallbeispiel illustriert ein in der Praxis häufiges Muster: Eine Architekturentscheidung wird konzeptionell korrekt getroffen, in der Umsetzung jedoch unter Zeitdruck nicht konsequent durchgehalten. Genau hier setzt Softwarequalitätsmanagement an — nicht als nachträgliche Kritik, sondern als Instrument, um solche Abweichungen systematisch zu identifizieren, zu bewerten und dauerhaft zu beheben @kube[S.~5].
