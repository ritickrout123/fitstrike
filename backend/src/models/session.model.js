import mongoose from 'mongoose';

const sessionSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  userId: { type: String, required: true, index: true },
  username: { type: String, required: true },
  path: [{
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
    timestamp: { type: Date, default: Date.now },
    accuracy: { type: Number },
    speed: { type: Number }
  }],
  startTime: { type: Date, required: true },
  endTime: { type: Date },
  duration: { type: Number },
  distance: { type: Number, default: 0 }, // in meters
  avgSpeed: { type: Number, default: 0 }, // in km/h
  maxSpeed: { type: Number, default: 0 },
  territoriesCaptured: { type: Number, default: 0 },
  areaCapture: { type: Number, default: 0 }, // in sqm
  xpEarned: { type: Number, default: 0 },
  coinsEarned: { type: Number, default: 0 },
  missionsCompleted: [{ type: String }],
  weatherCondition: { type: String },
  deviceInfo: {
    platform: { type: String },
    osVersion: { type: String }
  },
  createdAt: { type: Date, default: Date.now }
});

// Path array should NOT be indexed as per instructions
// Added index for userId only

const Session = mongoose.model('Session', sessionSchema);

export default Session;
