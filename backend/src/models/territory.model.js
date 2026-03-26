class Territory {
  constructor(row) {
    this.id = row.id;
    this.ownerId = row.owner_id;
    this.ownerUsername = row.owner_username;
    this.ownerColor = row.owner_color;
    this.clanId = row.clan_id;
    this.polygon = typeof row.polygon_geojson === 'string' 
      ? JSON.parse(row.polygon_geojson) 
      : row.polygon_geojson;
    this.areaSqm = row.area_sqm;
    this.isFortified = row.is_fortified;
    this.capturedAt = row.captured_at;
    this.decaysAt = row.decays_at;
  }

  toJSON() {
    return {
      id: this.id,
      ownerId: this.ownerId,
      ownerUsername: this.ownerUsername,
      ownerColor: this.ownerColor,
      clanId: this.clanId,
      polygon: this.polygon,
      areaSqm: this.areaSqm,
      isFortified: this.isFortified,
      capturedAt: this.capturedAt,
      decaysAt: this.decaysAt
    };
  }
}

export default Territory;
