export async function initPostGIS(pgPool) {
  const client = await pgPool.connect();
  try {
    console.log('🚀 Running PostGIS migrations...');
    
    await client.query('CREATE EXTENSION IF NOT EXISTS postgis;');
    
    await client.query(`
      CREATE TABLE IF NOT EXISTS territories (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        owner_id VARCHAR(255) NOT NULL,
        owner_username VARCHAR(255) NOT NULL,
        owner_color VARCHAR(7) NOT NULL,
        clan_id VARCHAR(255),
        polygon GEOMETRY(POLYGON, 4326) NOT NULL,
        area_sqm FLOAT NOT NULL,
        is_fortified BOOLEAN DEFAULT false,
        fortified_until TIMESTAMP,
        xp_value INT DEFAULT 10,
        coin_value INT DEFAULT 5,
        captured_at TIMESTAMP DEFAULT NOW(),
        decays_at TIMESTAMP,
        CONSTRAINT valid_polygon 
          CHECK (ST_IsValid(polygon))
      );
    `);
    
    await client.query('CREATE INDEX IF NOT EXISTS territories_polygon_idx ON territories USING GIST(polygon);');
    await client.query('CREATE INDEX IF NOT EXISTS territories_owner_idx ON territories(owner_id);');
    await client.query('CREATE INDEX IF NOT EXISTS territories_clan_idx ON territories(clan_id);');
    
    console.log('✅ PostGIS schema verified');
  } catch (err) {
    console.error('❌ PostGIS initialization failed:', err);
    throw err;
  } finally {
    client.release();
  }
}
