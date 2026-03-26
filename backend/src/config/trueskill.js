import { TrueSkill, Rating } from 'ts-trueskill';

// Faster convergence for fitness (fewer games to stabilize)
export const ts = new TrueSkill({
  mu: 25,           // Starting rating
  sigma: 25 / 3,    // Uncertainty (default)
  beta: 25 / 6,      // Skill distance for 80% win prob
  tau: 25 / 300,    // Dynamic factor (increase for faster convergence)
  drawProbability: 0.1 // Fitness has fewer true draws than chess
});

/**
 * Calculates the quality of a match between two squads.
 * @param {Array} squadA - Array of ratings for squad A
 * @param {Array} squadB - Array of ratings for squad B
 * @returns {number} Match quality (0 to 1)
 */
export function getMatchQuality(squadA, squadB) {
  const quality = ts.quality([squadA, squadB]);
  return quality;
}

export { Rating };
