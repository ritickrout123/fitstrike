import { HttpError } from '../../lib/http-error.js';

export function createClanService({ Clan, User, pgPool, redisService }) {
  async function createClan({ name, tag, leaderId, description }) {
    const existing = await Clan.findOne({ $or: [{ name }, { tag }] });
    if (existing) {
      throw new HttpError(409, 'CLAN_EXISTS', 'Clan name or tag already taken.');
    }

    const clan = new Clan({
      id: `clan_${Date.now()}`,
      name,
      tag,
      description,
      leaderId,
      memberIds: [leaderId],
      memberCount: 1
    });

    await clan.save();

    // Update leader's user record
    await User.updateOne({ id: leaderId }, { clanId: clan.id, clanRole: 'leader' });

    return clan;
  }

  async function getClanDetails(clanId) {
    const clan = await Clan.findOne({ id: clanId }).lean();
    if (!clan) throw new HttpError(404, 'CLAN_NOT_FOUND', 'Clan not found');

    return clan;
  }

  async function getClanTerritories(clanId) {
    const query = `
      SELECT *, ST_AsGeoJSON(polygon) as polygon_geojson
      FROM territories
      WHERE clan_id = $1;
    `;
    const { rows } = await pgPool.query(query, [clanId]);
    return rows;
  }

  async function joinClan(clanId, userId) {
    const clan = await Clan.findOne({ id: clanId });
    if (!clan) throw new HttpError(404, 'CLAN_NOT_FOUND', 'Clan not found');
    
    if (clan.memberCount >= clan.maxMembers) {
      throw new HttpError(400, 'CLAN_FULL', 'Clan is at max capacity.');
    }

    if (clan.memberIds.includes(userId)) return clan;

    clan.memberIds.push(userId);
    clan.memberCount = clan.memberIds.length;
    await clan.save();

    await User.updateOne({ id: userId }, { clanId: clan.id, clanRole: 'member' });

    return clan;
  }

  return {
    createClan,
    getClanDetails,
    getClanTerritories,
    joinClan
  };
}
