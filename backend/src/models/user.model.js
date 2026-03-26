import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';

const userSchema = new mongoose.Schema({
  id: { type: String, default: uuidv4, unique: true },
  username: {
    type: String,
    required: true,
    unique: true,
    minLength: 3,
    maxLength: 20,
    trim: true,
    lowercase: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  passwordHash: { type: String, required: true, select: false },
  level: { type: Number, default: 1, min: 1, max: 50 },
  xp: { type: Number, default: 0 },
  xpToNextLevel: { type: Number, default: 500 },
  strikeCoin: { type: Number, default: 100 },
  totalDistance: { type: Number, default: 0 },
  totalArea: { type: Number, default: 0 },
  captureCount: { type: Number, default: 0 },
  territoryColor: { type: String, default: '#C8FF00' },
  avatarUrl: { type: String },
  clanId: { type: String, default: null },
  clanRole: {
    type: String,
    enum: ['member', 'officer', 'leader'],
    default: 'member'
  },
  squadId: { type: String, default: null },
  isPremium: { type: Boolean, default: false },
  premiumUntil: { type: Date },
  battlePassTier: { type: Number, default: 0 },
  currentStreak: { type: Number, default: 0 },
  longestStreak: { type: Number, default: 0 },
  lastActiveDate: { type: Date },
  dailyMissionsCompleted: [{ type: String }],
  achievements: [{ type: String }],
  fcmToken: { type: String, select: false },
  isOnline: { type: Boolean, default: false },
  lastSeen: { type: Date, default: Date.now },
  createdAt: { type: Date, default: Date.now }
});

// Pre-save hook for password hashing and XP calculation
userSchema.pre('save', async function (next) {
  if (this.isModified('passwordHash')) {
    this.passwordHash = await bcrypt.hash(this.passwordHash, 12);
  }
  
  if (this.isModified('level')) {
    this.xpToNextLevel = this.level * 500;
  }
  
  next();
});

// Instance method to compare password
userSchema.methods.comparePassword = function (candidate) {
  return bcrypt.compare(candidate, this.passwordHash);
};

// Static method to find by email (including passwordHash)
userSchema.statics.findByEmail = function (email) {
  return this.findOne({ email: email.toLowerCase() }).select('+passwordHash');
};

const User = mongoose.model('User', userSchema);

export default User;
