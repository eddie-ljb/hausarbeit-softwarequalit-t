#import "@preview/clean-dhbw:0.4.0": *
#import "glossary.typ": glossary-entries

#show: clean-dhbw.with(
  title: "Softwarequalität",
  authors: (
    (name: "Etienne Luke Josef Bader", student-id: "9578543", course: "TINF23B2", course-of-studies: "Informatik"),
  ),
  city: "Karlsruhe",
  type-of-thesis: "Hausarbeit",
  at-university: true, // if true the company name on the title page and the confidentiality statement are hidden
  bibliography: bibliography("sources.bib"),
  date: datetime.today(),
  glossary: glossary-entries, // displays the glossary terms defined in "glossary.typ"
  language: "de", // en, de
  supervisor: (university: "Dennis Kube, Jonathan Schwarzenböck"),
  university: "Duale Hochschule Baden-Württemberg",
  university-location: "Karlsruhe",
  university-short: "DHBW",
  // for more options check the package documentation (https://typst.app/universe/package/clean-dhbw)
)

= Einleitung

= Grundlagen

== ISO/IEC 25010

== Clean Architecture & Dependency Rule

= Betrachtung: Architektur des Projekts

== Schichtenstruktur

== Stärken der Umsetzung

== Der kritische Befund

= Analyse und Bewertung

== Warum ist das kritisch?

== Bewertung mit FMEA/RPZ

== Widerspruch zur eigenen Dokumentation

= Optimierungsmaßnahmen

== Repository-Zugriffe in Controller eliminieren 

== Service-Annotation verschieben

== Erwartete Auswirkungen im PDCA-Rahmen

= Fazit 