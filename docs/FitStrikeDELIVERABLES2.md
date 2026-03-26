+-----------------------------------------------------------------------+
| **FITSTRIKE**                                                         |
|                                                                       |
| COMPREHENSIVE DEVELOPER & ARCHITECTURE DOCUMENTATION                  |
|                                                                       |
| Flutter • Flame Engine • Node.js • MongoDB • Redis                    |
|                                                                       |
| Version 2.0 | March 2026 | Technical Implementation Guide             |
+-----------------------------------------------------------------------+

TABLE OF CONTENTS
-----------------------------------------------------------------------
1. Technology Stack & Architecture
2. Flutter Implementation (UI + Flame Engine)
3. Backend Microservices Architecture
4. Database Schema & Geospatial Indexing
5. Real-Time Systems (WebSocket + Chat)
6. Game Engine Integration (Flame)
7. GPS & Territory Algorithms
8. Security & Anti-Cheat
9. Performance Optimization
10. Deployment & DevOps

=======================================================================
SECTION 1: TECHNOLOGY STACK
=======================================================================

1.1 Confirmed Technology Choices

MOBILE CLIENT:
Framework: Flutter 3.19+ (Dart 3)
Game Engine: Flame 1.16+ (for animations, particle effects)
State Management: Riverpod 2.4+ (reactive, type-safe)
Maps: flutter_map 6.1+ (OpenStreetMap, offline capable)
Local DB: Hive 2.2+ (fast NoSQL for offline queue)

BACKEND INFRASTRUCTURE:
Runtime: Node.js 20 LTS (Express.js)
Real-time: Socket.IO 4.7+ (WebSocket with fallbacks)
Database: MongoDB 7.0 (Mongoose ODM) + PostGIS for complex geo
Cache: Redis 7.2 (sessions, leaderboards, rate limiting)
Queue: BullMQ (Redis-based job queues)
Search: Elasticsearch (user search, territory history)

AI/ML SERVICES:
Language: Python 3.11 (FastAPI)
Models: TensorFlow Lite (on-device), PyTorch (server)
Features: Form correction, meal recognition, route optimization

DEVOPS:
Container: Docker + Docker Compose
Orchestration: Kubernetes (EKS/GKE)
CDN: CloudFlare (map tiles, assets)
CI/CD: GitHub Actions
Monitoring: Datadog + Sentry

1.2 Why Flutter + Flame?

Flutter Benefits:
- Single codebase for iOS/Android
- 60fps consistent performance
- Hot reload for rapid iteration
- Rich ecosystem (plugins)
- Native performance (Dart compiles to ARM)

Flame Engine Benefits:
- 2D game engine optimized for mobile
- Particle systems (explosions, sparkles on capture)
- Sprite animation (character avatars)
- Collision detection (territory overlap)
- Game loop for real-time updates

=======================================================================
SECTION 2: FLUTTER ARCHITECTURE
=======================================================================

2.1 Project Structure

fitstrike/
├── android/                    # Android-specific config
├── ios/                        # iOS-specific config
├── lib/
│   ├── main.dart
│   ├── app.dart               # MaterialApp configuration
│   ├── config/                # Routes, themes, constants
│   │   ├── routes.dart        # GoRouter configuration
│   │   ├── theme.dart         # Design system tokens
│   │   └── constants.dart     # API endpoints, keys
│   │
│   ├── core/                  # Shared utilities
│   │   ├── errors/            # Exception handling
│   │   ├── extensions/        # Dart extensions
│   │   └── utils/             # Helpers, formatters
│   │
│   ├── features/              # Feature-first architecture
│   │   ├── auth/
│   │   │   ├── data/          # Repositories, models
│   │   │   ├── domain/        # Entities, use cases
│   │   │   └── presentation/  # BLoC, screens, widgets
│   │   │
│   │   ├── map/               # GPS, territory, game
│   │   │   ├── game/          # Flame game components
│   │   │   ├── widgets/       # Map overlays, HUD
│   │   │   └── blocs/         # MapCubit, TrackingCubit
│   │   │
│   │   ├── gym/               # Workout logging
│   │   ├── nutrition/         # Food tracking
│   │   ├── social/            # Chat, clans, friends
│   │   ├── events/            # Tournaments, raids
│   │   └── profile/           # Stats, settings
│   │
│   ├── services/              # Singleton services
│   │   ├── location_service.dart      # GPS tracking
│   │   ├── socket_service.dart        # Real-time comms
│   │   ├── notification_service.dart  # Push notifications
│   │   └── audio_service.dart         # Sound effects
│   │
│   └── shared/                # Shared widgets
│       ├── buttons.dart
│       ├── cards.dart
│       └── animations.dart
│
├── assets/                    # Images, fonts, sounds
├── test/                      # Unit & widget tests
└── integration_test/          # E2E tests


2.2 State Management (Riverpod)

```dart
// Provider definitions
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier(ref.read(apiServiceProvider));
});

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(
    ref.read(locationServiceProvider),
    ref.read(socketServiceProvider),
  );
});

final chatProvider = StreamProvider.family<List<Message>, String>((ref, channelId) {
  return ref.read(chatRepositoryProvider).getMessages(channelId);
});


// Main game class for territory visualization
class TerritoryGame extends FlameGame with PanDetector, ScaleDetector {
  late CameraComponent camera;
  late World world;
  
  // Game components
  final Map<String, TerritoryPolygon> territories = {};
  final Map<String, PlayerMarker> players = {};
  late PlayerAvatar userAvatar;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    world = World();
    camera = CameraComponent(world: world);
    addAll([world, camera]);
    
    // Load map tiles
    add(MapTileComponent());
    
    // Initialize user
    userAvatar = PlayerAvatar(
      position: Vector2.zero(),
      color: user.territoryColor,
    );
    world.add(userAvatar);
  }
  
  void onTerritoryCaptured(Territory territory) {
    // Particle explosion effect
    add(ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2.random() * 100,
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = territory.color,
          ),
        ),
      ),
      position: territory.center,
    ));
    
    // Screen shake
    camera.viewfinder.add(
      MoveByEffect(
        Vector2(5, 5),
        EffectController(duration: 0.1, repeatCount: 3, alternate: true),
      ),
    );
  }
}


======================================================================= SECTION 3: BACKEND ARCHITECTURE
3.1 Microservices Overview

┌─────────────────────────────────────────────────────────────┐
│                        API Gateway (Kong)                    │
│                   Rate Limiting, Auth, SSL                   │
└──────────────┬──────────────────────────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐  ┌─────▼──────┐  ┌──────────┐  ┌──────────┐
│   Auth      │  │   Game     │  │  Social  │  │  Analytics│
│  Service    │  │  Service   │  │ Service  │  │ Service   │
│  (Node.js)  │  │  (Node.js) │  │(Node.js) │  │ (Python)  │
└──────┬──────┘  └─────┬──────┘  └────┬─────┘  └────┬─────┘
       │               │              │             │
       └───────────────┴──────────────┴─────────────┘
                       │
              ┌────────▼────────┐
              │   Message Bus   │
              │  (Redis PubSub) │
              └────────┬────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   ┌────▼────┐   ┌────▼────┐   ┌─────▼─────┐
   │ MongoDB │   │PostGIS  │   │Elasticsearch│
   │ (Users) │   │(Geo)    │   │ (Search)    │
   └─────────┘   └─────────┘   └─────────────┘

3.2 Core Services
A. AUTH SERVICE (Port 3001)
JWT issuance & validation
Social OAuth (Google, Apple, Facebook)
Refresh token rotation
Device management
B. GAME SERVICE (Port 3002)
Territory calculations
Session management
Scoring & XP
Anti-cheat validation
C. SOCIAL SERVICE (Port 3003)
Clan management
Chat persistence
Friend graphs
Activity feeds
D. NOTIFICATION SERVICE (Port 3004)
Push notification dispatch (FCM/APNs)
Email notifications
SMS (for critical alerts)
In-app notification center
3.3 API Endpoints
yaml
Copy
# Territory API
POST   /v1/territories/capture      # Create territory from GPS path
GET    /v1/territories/nearby       # Get polygons near lat/lng
DELETE /v1/territories/{id}         # Decay old territories
WS     /v1/territories/stream       # Real-time updates

# Clan API
POST   /v1/clans                    # Create clan
GET    /v1/clans/{id}               # Get clan details
POST   /v1/clans/{id}/join          # Request to join
POST   /v1/clans/{id}/war           # Declare war
GET    /v1/clans/leaderboard        # Clan rankings

# Chat API
GET    /v1/channels                 # List user's channels
POST   /v1/channels/{id}/messages   # Send message
GET    /v1/channels/{id}/messages   # Get history (paginated)
WS     /v1/channels/{id}/live       # Real-time messages

# Event API
GET    /v1/events                   # List active events
POST   /v1/events/{id}/register     # Sign up for event
GET    /v1/events/{id}/leaderboard  # Live event scores
======================================================================= SECTION 4: DATABASE SCHEMA
4.1 MongoDB Collections
JavaScript
Copy
// USERS COLLECTION
{
  _id: ObjectId,
  username: String,           // unique, indexed
  email: String,              // unique, indexed
  passwordHash: String,       // bcrypt
  profile: {
    displayName: String,
    avatar: String,           // URL or asset ID
    territoryColor: String,   // hex code
    level: Number,            // 0-50
    xp: Number,
    title: String             // "Raider", "Champion", etc.
  },
  stats: {
    totalDistance: Number,    // meters
    totalArea: Number,        // m²
    workoutsCompleted: Number,
    territoryCaptures: Number
  },
  economy: {
    strikeCoins: Number,
    premiumExpires: Date,
    battlePassTier: Number
  },
  social: {
    clanId: ObjectId,
    friends: [ObjectId],
    blocked: [ObjectId]
  },
  settings: {
    notifications: Boolean,
    privacy: String,          // public, friends, private
    units: String             // metric, imperial
  },
  createdAt: Date,
  lastActive: Date
}

// TERRITORIES COLLECTION (GeoJSON)
{
  _id: ObjectId,
  userId: ObjectId,           // indexed
  clanId: ObjectId,           // for clan territories
  polygon: {
    type: "Polygon",
    coordinates: [[[Number]]] // GeoJSON format
  },
  center: {
    type: "Point",
    coordinates: [lng, lat]   // 2dsphere index
  },
  area: Number,               // m², computed
  color: String,              // hex
  properties: {
    fortified: Boolean,
    captureCount: Number,
    createdAt: Date,
    expiresAt: Date           // for decay
  }
}

// CLANS COLLECTION
{
  _id: ObjectId,
  name: String,               // unique
  tag: String,                // 3-4 chars, unique
  description: String,
  leaderId: ObjectId,
  officers: [ObjectId],
  members: [{
    userId: ObjectId,
    role: String,             // recruit, member, officer
    joinedAt: Date
  }],
  stats: {
    totalArea: Number,
    warsWon: Number,
    level: Number             // clan level 1-20
  },
  resources: {
    bank: Number,             // Strike Coins
    upgrades: [String]        // unlocked perks
  },
  createdAt: Date
}

// MESSAGES COLLECTION (Time-series)
{
  _id: ObjectId,
  channelId: String,          // "global", "clan:{id}", "user:{id}"
  senderId: ObjectId,
  type: String,               // text, image, voice, system
  content: String,
  metadata: {
    replyTo: ObjectId,
    reactions: [{userId, emoji}],
    edited: Boolean
  },
  timestamp: Date             // TTL index (90 days)
}

// EVENTS COLLECTION
{
  _id: ObjectId,
  type: String,               // war, raid, challenge, tournament
  status: String,             // upcoming, active, completed
  schedule: {
    startTime: Date,
    endTime: Date,
    timezone: String
  },
  location: {
    type: "Polygon",          // Geofenced area
    coordinates: [[[Number]]]
  },
  participants: [ObjectId],   // registered users/clans
  rules: {
    minLevel: Number,
    maxParticipants: Number,
    scoring: String
  },
  rewards: {
    coins: Number,
    xp: Number,
    items: [String]           // cosmetic IDs
  }
}
4.2 Redis Data Structures
bash
Copy
# Leaderboards (Sorted Sets)
ZADD leaderboard:global <score> <userId>
ZADD leaderboard:weekly:${week} <score> <userId>
ZADD leaderboard:clan:${clanId} <score> <userId>

# Real-time Presence (Hash)
HSET presence:${userId} status online lastSeen ${timestamp} location "${lat},${lng}"

# Chat Channels (Lists)
LPUSH chat:${channelId} ${messageJson}
LTRIM chat:${channelId} 0 100  # Keep last 100 messages

# Rate Limiting (String with expiry)
SET rateLimit:${userId}:api 1 EX 60 NX  # 1 request per minute

# Session Store (Hash)
HSET session:${sessionId} userId ${id} device ${device} startTime ${time}
======================================================================= SECTION 5: REAL-TIME SYSTEMS
5.1 Socket.IO Events
JavaScript
Copy
// Client to Server
socket.emit('location:update', {
  lat: 28.6139,
  lng: 77.2090,
  accuracy: 5,
  timestamp: Date.now(),
  sessionId: 'sess_123'
});

socket.emit('chat:message', {
  channelId: 'clan_456',
  content: 'Let\'s raid the park!',
  type: 'text'
});

socket.emit('territory:claim', {
  path: [[lat, lng], [lat, lng], ...],
  sessionId: 'sess_123'
});

// Server to Client
socket.on('territory:captured', (data) => {
  // { area: 450, fromUser: 'RivalName', location: [lat, lng] }
  showToast(`Captured ${data.area}m² from ${data.fromUser}!`);
  playCaptureAnimation();
});

socket.on('rival:nearby', (data) => {
  // { userId: '...', distance: 50, location: [lat, lng] }
  updateRivalMarker(data);
});

socket.on('clan:war:update', (data) => {
  // Live war scores, territory changes
  updateWarHUD(data);
});
5.2 Chat Architecture
dart
Copy
// Flutter chat implementation
class ChatRepository {
  final SocketService _socket;
  final LocalDatabase _db;
  
  Stream<List<Message>> getMessages(String channelId) async* {
    // 1. Load cached messages from Hive
    final cached = await _db.getMessages(channelId);
    yield cached;
    
    // 2. Connect to Socket.IO room
    _socket.joinChannel(channelId);
    
    // 3. Listen for new messages
    await for (final msg in _socket.messageStream) {
      if (msg.channelId == channelId) {
        await _db.saveMessage(msg);
        yield await _db.getMessages(channelId);
      }
    }
  }
  
  Future<void> sendMessage(String channelId, String content) async {
    // Optimistic update
    final tempMsg = Message.temp(content: content);
    await _db.saveMessage(tempMsg);
    
    // Send via socket
    _socket.emit('chat:message', {
      'channelId': channelId,
      'content': content,
    });
  }
}
======================================================================= SECTION 6: GAME ENGINE (FLAME) INTEGRATION
6.1 Territory Visualization
dart
Copy
class TerritoryPolygon extends PolygonComponent {
  final String ownerId;
  final Color fillColor;
  final bool isFortified;
  
  TerritoryPolygon({
    required List<Vector2> points,
    required this.ownerId,
    required this.fillColor,
    this.isFortified = false,
  }) : super(points) {
    paint = Paint()
      ..color = fillColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    // Border
    final borderPaint = Paint()
      ..color = isFortified ? Colors.gold : fillColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    // Add pulse animation for fortified
    if (isFortified) {
      add(FortifiedPulseEffect());
    }
  }
}

class FortifiedPulseEffect extends Component with HasGameRef {
  double _timer = 0;
  
  @override
  void update(double dt) {
    _timer += dt;
    final opacity = (sin(_timer * 2) + 1) / 2 * 0.5 + 0.2;
    parent?.paint.color = parent?.paint.color.withOpacity(opacity);
  }
}
6.2 Particle Effects
dart
Copy
class CaptureEffect extends ParticleSystemComponent {
  CaptureEffect({required Vector2 position})
      : super(
          particle: Particle.generate(
            count: 100,
            lifespan: 1.5,
            generator: (i) {
              final angle = random.nextDouble() * 2 * pi;
              final speed = random.nextDouble() * 100 + 50;
              return AcceleratedParticle(
                acceleration: Vector2(cos(angle), sin(angle)) * speed,
                child: CircleParticle(
                  radius: random.nextDouble() * 3 + 1,
                  paint: Paint()..color = Colors.lime,
                ),
              );
            },
          ),
          position: position,
        );
}
======================================================================= SECTION 7: GPS & TERRITORY ALGORITHMS
7.1 Path to Polygon Conversion
JavaScript
Copy
const turf = require('@turf/turf');

function createTerritoryFromPath(path, userId) {
  // 1. Create LineString from GPS points
  const line = turf.lineString(path.map(p => [p.lng, p.lat]));
  
  // 2. Buffer based on speed (walking 5m, running 8m)
  const avgSpeed = calculateAverageSpeed(path);
  const buffer = avgSpeed > 10 ? 0.008 : 0.005; // km
  
  const buffered = turf.buffer(line, buffer, { units: 'kilometers' });
  
  // 3. Simplify to reduce points (Douglas-Peucker)
  const simplified = turf.simplify(buffered, { tolerance: 0.0001 });
  
  // 4. Calculate area
  const area = turf.area(simplified); // m²
  
  return {
    polygon: simplified.geometry,
    area: area,
    center: turf.center(simplified).geometry.coordinates
  };
}
7.2 Capture Detection
JavaScript
Copy
async function detectCaptures(newTerritory, attackerId) {
  // Find overlapping territories
  const overlaps = await Territory.find({
    userId: { $ne: attackerId },
    polygon: {
      $geoIntersects: {
        $geometry: newTerritory.polygon
      }
    }
  });
  
  const captures = [];
  
  for (const enemy of overlaps) {
    // Calculate intersection
    const intersection = turf.intersect(
      turf.feature(newTerritory.polygon),
      turf.feature(enemy.polygon)
    );
    
    if (!intersection) continue;
    
    const area = turf.area(intersection);
    if (area < 50) continue; // Minimum threshold
    
    // Subtract from enemy
    const remaining = turf.difference(
      turf.feature(enemy.polygon),
      intersection
    );
    
    if (remaining) {
      enemy.polygon = remaining.geometry;
      await enemy.save();
    } else {
      await enemy.delete();
    }
    
    // Add to attacker
    captures.push({
      from: enemy.userId,
      area: area,
      geometry: intersection.geometry
    });
  }
  
  return captures;
}
======================================================================= SECTION 8: SECURITY & ANTI-CHEAT
8.1 GPS Validation Rules
JavaScript
Copy
function validateGPSPoint(point, lastPoint) {
  const errors = [];
  
  // Speed check
  if (lastPoint) {
    const timeDiff = (point.timestamp - lastPoint.timestamp) / 1000;
    const dist = calculateDistance(point, lastPoint);
    const speed = (dist / timeDiff) * 3.6; // km/h
    
    if (speed > 40) {
      errors.push('SPEED_VIOLATION');
    }
    
    if (speed > 100) {
      errors.push('TELEPORT_DETECTED');
      flagForReview(userId);
    }
  }
  
  // Accuracy check
  if (point.accuracy > 50) {
    errors.push('LOW_ACCURACY');
  }
  
  // Drift check (same position for too long)
  if (lastPoint && distance(point, lastPoint) < 1) {
    if (Date.now() - lastPoint.timestamp > 300000) { // 5 min
      errors.push('GPS_DRIFT');
    }
  }
  
  return errors;
}
8.2 Encryption & Privacy
Location data: Encrypted at rest (AES-256)
In transit: TLS 1.3
PII: Tokenized in analytics
GDPR: Right to deletion implemented (cascade delete)
Precise location: Never shared publicly (only territory polygons)
======================================================================= SECTION 9: PERFORMANCE OPTIMIZATION
9.1 Mobile Optimizations
dart
Copy
// Map tile caching
class MapTileProvider extends TileProvider {
  final CacheManager _cache = CacheManager(
    Config('mapTiles', maxNrOfCacheObjects: 500),
  );
  
  @override
  Future<Tile> getTile(Coords coords) async {
    final file = await _cache.getFileFromCache(url);
    if (file != null) return Tile(file.file.readAsBytesSync());
    
    final response = await http.get(Uri.parse(url));
    await _cache.putFile(url, response.bodyBytes);
    return Tile(response.bodyBytes);
  }
}

// Lazy loading territories
class TerritoryManager {
  Stream<List<Territory>> getTerritoriesInViewport(LatLngBounds bounds) {
    return _db.watchTerritories().map((list) {
      return list.where((t) => bounds.contains(t.center)).toList();
    });
  }
}
9.2 Backend Optimizations
DB Query Optimization: Covered indexes for geo queries
Caching Strategy: Redis for active territories (5min TTL)
CDN: Map tiles cached at edge
Connection Pooling: 1000 concurrent DB connections
GraphQL: DataLoader for N+1 prevention
======================================================================= SECTION 10: DEPLOYMENT
10.1 Docker Compose (Development)
yaml
Copy
version: '3.8'
services:
  app:
    build: ./mobile
    volumes:
      - ./mobile:/app
    ports:
      - "8080:8080"
      
  api:
    build: ./backend
    environment:
      - MONGO_URI=mongodb://mongo:27017/fitstrike
      - REDIS_URI=redis://redis:6379
    ports:
      - "3000:3000"
      
  mongo:
    image: mongo:7
    volumes:
      - mongo_data:/data/db
      
  redis:
    image: redis:7-alpine
    
volumes:
  mongo_data:
10.2 Kubernetes (Production)
yaml
Copy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fitstrike-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fitstrike-api
  template:
    spec:
      containers:
      - name: api
        image: fitstrike/api:latest
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        env:
        - name: NODE_ENV
          value: "production"

