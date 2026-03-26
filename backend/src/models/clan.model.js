import mongoose from 'mongoose';

const clanSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true, unique: true },
  tag: { type: String, required: true, unique: true, minLength: 2, maxLength: 5 },
  description: { type: String },
  emblemUrl: { type: String },
  color: { type: String, default: '#C8FF00' },
  leaderId: { type: String, required: true },
  officerIds: [{ type: String }],
  memberIds: [{ type: String }],
  memberCount: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  totalXp: { type: Number, default: 0 },
  totalArea: { type: Number, default: 0 },
  winCount: { type: Number, default: 0 },
  lossCount: { type: Number, default: 0 },
  isRecruiting: { type: Boolean, default: true },
  maxMembers: { type: Number, default: 50 },
  createdAt: { type: Date, default: Date.now }
});

const Clan = mongoose.model('Clan', clanSchema);

export default Clan;
