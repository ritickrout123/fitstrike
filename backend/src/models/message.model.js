import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  channelId: { type: String, required: true, index: true },
  senderId: { type: String, index: true }, // null for system messages
  senderUsername: { type: String },
  senderColor: { type: String },
  content: { type: String, required: true },
  type: { type: String, enum: ['text', 'system', 'image'], default: 'text' },
  createdAt: { type: Date, default: Date.now }
});

const Message = mongoose.model('Message', messageSchema);

export default Message;
