/**
 * Lua script for atomic GEORADIUS + online check
 * KEYS[1]: Redis key for Geo data (e.g. 'presence:geo')
 * KEYS[2]: Redis key for Online set (e.g. 'presence:online')
 * ARGV[1]: Longitude
 * ARGV[2]: Latitude
 * ARGV[3]: Radius (meters)
 * ARGV[4]: Target squad size (e.g. 4)
 */
export const MATCH_LUA_SCRIPT = `
  local players = redis.call('georadius', KEYS[1], ARGV[1], ARGV[2], ARGV[3], 'm', 'WITHDIST');
  local valid = {};
  for i, p in ipairs(players) do
    if redis.call('sismember', KEYS[2], p[1]) == 1 then
      table.insert(valid, p[1]);
      if #valid >= tonumber(ARGV[4]) then break end;
    end
  end
  if #valid >= tonumber(ARGV[4]) then
    for i, pid in ipairs(valid) do
      -- We don't remove from GEO here yet, 
      -- we let the service handle the transaction
      -- redis.call('zrem', KEYS[1], pid); 
    end
    return valid;
  end
  return {};
`;
