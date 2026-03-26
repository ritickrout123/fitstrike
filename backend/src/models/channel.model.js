import mongoose from 'mongoose';

const channelSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  type: {
    type: String,
    enum: ['global', 'clan', 'local', 'dm'],
    required: true
  },
  name: { type: String, required: true },
  participants: [{ type: String }], // userIds
  preview: { type: String },
  unreadCount: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

const Channel = mongoose.model('Channel', channelSchema);

export default Channel;
