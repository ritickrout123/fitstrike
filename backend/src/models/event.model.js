import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  type: {
    type: String,
    enum: ['flash', 'daily', 'raid', 'territory_war', 'seasonal'],
    required: true
  },
  title: { type: String, required: true },
  description: { type: String },
  theme: { type: String },
  startTime: { type: Date, required: true },
  endTime: { type: Date, required: true },
  duration: { type: Number },
  status: {
    type: String,
    enum: ['upcoming', 'active', 'completed'],
    default: 'upcoming'
  },
  participants: [{ type: String }], // userIds
  rewards: {
    xp: { type: Number, default: 0 },
    coins: { type: Number, default: 0 },
    item: { type: String },
    exclusive: { type: String }
  },
  config: { type: mongoose.Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now }
});

const Event = mongoose.model('Event', eventSchema);

export default Event;
