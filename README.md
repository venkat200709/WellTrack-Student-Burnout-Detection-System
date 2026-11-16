# WellTrack

**An AI-powered student burnout detection and wellness monitoring system, built entirely in Java.**

CS5304 — Java Programming · Chennai Institute of Technology (Autonomous) · Department of CSE, Section A
Venkatesan N (2104251040604) · Needhivendhan T (2104251040629) · Mentor: Dr. Vignesh T

---

## What it does

Academic burnout is usually detected only when grades collapse — by which point recovery takes months rather than
weeks. WellTrack reads the signals that move *first*: sleep duration, study rhythm, screen time, physical activity,
social contact, self-reported stress, mood and attendance. It combines them into an explainable burnout score,
forecasts where that score is heading, and turns the result into one concrete action for tomorrow.

The system serves three audiences from a single codebase:

| Role | What they get |
|---|---|
| **Student** | Live burnout score with a full explanation, seven-day forecast, AI coach, what-if simulator, personalised action plan, streaks and badges |
| **Faculty mentor** | Cohort console, sortable roster, priority-contact queue, live alerts, discovered wellness cohorts, CSV export |
| **Administrator** | Institution-wide analytics, department breakdown, runtime metrics, live sessions, full security audit trail |

---

## Running it

**Requirements: a JDK 17 or newer. That is the complete list.**

No Maven, no Gradle, no database server, no internet connection, no downloaded jars.

### From IntelliJ IDEA (recommended for the review)

1. `File ▸ Open` and select the `WellTrackAI` folder.
2. If prompted, set the Project SDK to your installed JDK (17+).
3. In the Run configuration dropdown pick **WellTrack ▶ Start Server** and press ▶.
4. Open <http://localhost:8080>.

The run configurations for both the server and the test suite are committed in `.idea/runConfigurations`,
so they appear automatically.

### From a terminal

```bash
# Windows
run.bat

# macOS / Linux
./run.sh
```

### Running the tests

```bash
test.bat        # Windows
./test.sh       # macOS / Linux
```

73 automated checks covering the JSON engine, validation, security, persistence, routing, and every
machine-learning component.

---

## Demonstration accounts

The first launch detects an empty datastore and generates ninety days of realistic behavioural history for
ten students, each with a deliberate narrative arc so the charts show something worth discussing.

| Role | Username | Password | Story |
|---|---|---|---|
| Student | `venkat` | `Student@2026` | Risk rising steadily through the term |
| Student | `needhi` | `Student@2026` | Recovering — the forecast bends downward |
| Student | `sanjay` | `Student@2026` | Sustained high risk, cohort outlier |
| Faculty | `vignesh` | `Faculty@2026` | Mentor console with live alerts |
| Admin | `admin` | `Admin@2026` | Institution console and audit trail |

---

## The AI

Every model below is **implemented from first principles in Java**. There is no scikit-learn, no TensorFlow,
no API call — you can open each algorithm and read it.

| Capability | Implementation | File |
|---|---|---|
| Burnout prediction | Logistic regression, mini-batch gradient descent, L2 + momentum, class weighting, early stopping, F1-tuned threshold | `ai/engine/LogisticRegressionModel.java` |
| Explainable AI | Exact per-feature log-odds contributions, ranked and rendered as plain English | `ai/BurnoutPredictor.java`, `ai/FeatureCatalog.java` |
| Feature scaling | Z-score standardisation fitted once and reused at inference | `ai/engine/StandardScaler.java` |
| Forecasting | Damped Holt linear exponential smoothing, grid-searched α/β, residual-based prediction intervals | `ai/engine/HoltLinearForecaster.java` |
| Anomaly detection | Modified z-score on the median absolute deviation, plus EWMA drift | `ai/engine/AnomalyDetector.java` |
| Cohort discovery | K-means with k-means++ seeding and silhouette-based selection of *k* | `ai/engine/KMeansClusterer.java` |
| Intent understanding | Multinomial Naive Bayes, Laplace smoothing, log-space inference | `ai/nlp/NaiveBayesIntentClassifier.java` |
| Sentiment & emotion | Domain lexicon with negation scope, intensifiers and five emotion channels | `ai/nlp/SentimentAnalyzer.java` |
| Retrieval | TF-IDF vector space with cosine similarity over a curated knowledge base | `ai/nlp/TfIdfIndex.java` |
| Recommendation | Hybrid: content-based on the explanation, boosted by collaborative peer evidence | `ai/RecommendationEngine.java` |
| Conversational coach | Retrieval-augmented generation grounded in the student's own live data | `ai/WellnessCoach.java` |
| What-if simulator | Counterfactual scoring through the live model with per-lever sensitivity | `controller/AiController.java` |

### The ensemble

A single number would be fragile, so the score blends four independent estimators that fail differently:

| Member | Weight | Contribution |
|---|---|---|
| Logistic-regression model | 50% | Learns how the behaviours interact |
| Rule-based strain heuristic | 25% | Transparent domain knowledge; carries the full weight before the model finishes training |
| Statistical anomaly detector | 15% | Catches sudden collapses a smoothed average would hide |
| Trend component | 10% | Rewards genuine improvement, penalises steady decline |

### Model quality

Measured on a held-out validation split, printed at start-up and visible in the AI Lab view:

```
accuracy 82.6%   ·   recall 86.8%   ·   ROC-AUC 0.896   ·   log loss 0.404
```

Recall is deliberately prioritised: failing to flag a student heading for burnout costs far more than a false alarm.
Roughly 6% label noise is injected into the training simulation so the classes are *not* linearly separable — a
model reporting 100% accuracy would be a model that had memorised a shortcut.

### Where the training data comes from

A wellness system faces a genuine cold-start problem, and no public dataset can ship inside a coursework project.
`ai/TrainingDataFactory.java` solves it with a generative simulation grounded in occupational-health research:
each simulated student receives a hidden *burnout propensity*, and every observable behaviour is sampled as a
noisy function of it using effect directions established in the literature. Because the observations are noisy,
no single feature recovers the hidden state — the model has to learn how the signals combine, which is exactly the
skill required. The same simulator produces the demonstration histories, so seeded data is statistically
consistent with what the model learned.

---

## Security

| Concern | How it is handled |
|---|---|
| Password storage | PBKDF2-HMAC-SHA256, 210,000 iterations, 16-byte random salt per password, constant-time verification |
| Sessions | JSON Web Tokens signed with HMAC-SHA256, implemented from the specification, paired with a server-side registry so a token can be revoked before it expires |
| Login validation | Seven independent gates: shape validation, IP rate limiting, account lookup, active check, lockout window, credential verification, audit |
| Brute force | Token-bucket rate limiter per IP, plus account lockout after five failures |
| Authorisation | Declared per route and enforced by a filter, with role hierarchy and a self-or-elevated rule so students can only reach their own records |
| Audit | Every authentication attempt, lockout, password change and export is written to a retained audit trail |
| Enumeration | Uniform failure messaging so an attacker cannot discover which usernames exist |

---

## Project structure

```
WellTrackAI/
├── .idea/                          IntelliJ project + ready-made run configurations
├── src/main/java/com/welltrack/
│   ├── WellTrackApplication.java   Entry point and composition root
│   ├── core/                       The hand-written micro-framework
│   │   ├── json/                   JSON lexer, recursive-descent parser and writer
│   │   ├── http/                   Embedded server, router, filters, SSE stream
│   │   ├── di/                     Lazy singleton service registry
│   │   └── util/                   Config, logging, validation, numerics
│   ├── model/                      Domain entities and enums
│   │   └── enums/                  Role, RiskLevel, Mood, AlertSeverity, …
│   ├── repository/                 Generic repository + concrete repositories
│   │   └── datastore/              File, in-memory and JDBC storage engines
│   ├── security/                   PBKDF2, JWT, sessions, rate limiting, filter
│   ├── ai/                         The AI engine
│   │   ├── engine/                 Regression, clustering, forecasting, anomalies
│   │   └── nlp/                    Tokeniser, sentiment, TF-IDF, Naive Bayes
│   ├── service/                    Business logic and the analysis pipeline
│   ├── controller/                 REST endpoints
│   ├── dto/                        Validated request/response records
│   ├── exception/                  Typed failures carrying HTTP status
│   └── bootstrap/                  Demonstration data seeder
├── src/main/resources/
│   ├── application.properties      Documented defaults
│   └── web/                        The single-page interface
│       ├── index.html
│       ├── css/                    Design tokens and the component system
│       └── js/                     API client, UI toolkit, chart library, views
├── src/test/java/com/welltrack/    TestKit + 73 automated checks
├── sql/schema.sql                  Relational schema and reporting views
├── docs/                           Architecture and API reference
├── data/                           Runtime datastore (created on first launch)
├── run.bat / run.sh                One-command build and run
└── test.bat / test.sh              One-command test run
```

---

## Java concepts demonstrated

Mapped to the syllabus, with the file where each is most clearly visible:

| Concept | Where |
|---|---|
| **Class & Object** | `model/Student.java`, `model/BehaviorLog.java` |
| **Constructors & overloading** | `model/Student.java` (three constructors), `model/BehaviorLog.java` |
| **Encapsulation** | Private fields with accessors throughout `model/`; `passwordHash` is never serialised |
| **Inheritance** | `User` → `Student`, `Faculty`, `Administrator`; `Repository<T>` → eight concrete repositories |
| **Polymorphism** | `headline()` / `profileSummary()` overridden per role; `ApiException` subtypes carry their own status |
| **Abstraction** | `abstract class User`, `abstract class Repository<T>`, `interface Datastore`, `interface PasswordEncoder` |
| **Interfaces** | `Datastore`, `PasswordEncoder`, `RouteHandler`, `Filter`, `JsonSerializable`, `Identifiable` |
| **Generics** | `Repository<T extends Identifiable>`, `ServiceRegistry.get(Class<T>)` |
| **Collections** | `ConcurrentHashMap`, `LinkedHashMap`, `ArrayList`, `EnumMap`, `CopyOnWriteArraySet` |
| **Streams & lambdas** | `service/AnalyticsService.java`, `repository/Repository.java` |
| **Records** | `RiskDriver`, `LoginRequest`, `ModelMetrics`, `ForecastEngine.Forecast` |
| **Enums with behaviour** | `RiskLevel.of(score)`, `Mood.closestTo(valence)`, `Role.satisfies(role)` |
| **Exception handling** | Typed hierarchy in `exception/`, translated centrally in `WebServer` |
| **Multithreading** | Fixed HTTP pool, work-stealing analysis pool, `CompletableFuture` batches, scheduled daemons, background model training |
| **Concurrency control** | `ReentrantReadWriteLock` in `FileDatastore`, `AtomicLong` sequences, synchronized token buckets |
| **File I/O & NIO** | `FileDatastore` with atomic temp-file-and-move writes |
| **JDBC** | `JdbcDatastore` with prepared statements, batching and transactions |
| **String handling** | `StringBuilder` in the JSON writer and CSV exporter; text blocks throughout |
| **Regular expressions** | `core/util/Validation.java` |
| **Cryptography** | `javax.crypto` in `Pbkdf2PasswordEncoder` and `TokenService` |
| **Networking** | `com.sun.net.httpserver` server; `java.net.http.HttpClient` in `LlmClient` |
| **Date & time API** | `LocalDate`, `LocalDateTime`, `Duration`, `ChronoUnit` across the model |
| **Recursion** | The recursive-descent JSON parser |

---

## Interface

The front end is written in vanilla HTML, CSS and JavaScript with **no framework and no CDN dependency**, so it
works offline exactly as it does online.

- Animated aurora background, perspective grid and film grain
- Constellation particle field on the sign-in screen that reacts to the cursor
- Glassmorphic cards with cursor-tracking spotlights and gradient hairlines
- An animated SVG risk gauge with a counting readout
- A **hand-written canvas chart library** — area charts with forecast bands, sparklines, bars, donuts, scatter plots and progress rings, all animating their own draw-in
- Live server-sent-events channel: alerts, score updates and badges arrive as toasts without a refresh
- Command palette on `Ctrl` + `K`
- Full dark and light themes, driven entirely by CSS custom properties
- Reduced-motion and print stylesheets

---

## Configuration

Everything is optional — see `src/main/resources/application.properties`. Common overrides:

```bash
java -Dwelltrack.server.port=9090 -cp out com.welltrack.WellTrackApplication
```

To switch to MySQL: run `sql/schema.sql`, add the connector jar to the classpath, and set `datastore=jdbc`
with the matching `jdbc.*` properties.

---

## Scope and limitations

WellTrack is a **wellness indicator, not a clinical instrument**. It does not diagnose, does not prescribe, and
does not replace a counsellor. Where a student's language suggests genuine distress, the system stops giving
advice and routes them to a human — that behaviour is deliberate and is covered by the test suite.
