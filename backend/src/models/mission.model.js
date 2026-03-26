import mongoose from 'mongoose';

const missionSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  type: {
    type: String,
    enum: ['daily', 'weekly', 'event', 'clan'],
    required: true
  },
  title: { type: String, required: true },
  description: { type: String },
  icon: { type: String },
  requirement: {
    action: { type: String, required: true },
    target: { type: Number, required: true },
    current: { type: Number, default: 0 }
  },
  reward: {
    xp: { type: Number, default: 0 },
    coins: { type: Number, default: 0 },
    item: { type: String }
  },
  expiresAt: { type: Date },
  isActive: { type: Boolean, default: true }
});

const Mission = mongoose.model('Mission', missionSchema);

export default Mission;
