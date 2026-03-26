import { Router } from 'express';
import { requireAuth } from '../../middleware/require-auth.js';

export function buildUsersRouter(container) {
  const router = Router();

  router.get('/me', requireAuth(container), (request, response) => {
    response.json(container.userService.getPublicUser(request.auth.userId));
  });

  router.get('/me/today', requireAuth(container), (request, response) => {
    response.json(container.userService.getTodaySnapshot(request.auth.userId));
  });

  router.get('/me/gym-plan', requireAuth(container), (request, response) => {
    response.json(container.userService.getGymPlan(request.auth.userId));
  });

  router.post('/me/gym-plan/exercises/:exerciseId/complete', requireAuth(container), (request, response) => {
    response.json(
      container.userService.completeGymExercise(request.auth.userId, request.params.exerciseId)
    );
  });

  router.get('/me/nutrition', requireAuth(container), (request, response) => {
    response.json(container.userService.getNutrition(request.auth.userId));
  });

  router.post('/me/nutrition/meals', requireAuth(container), (request, response) => {
    response.status(201).json(container.userService.addNutritionMeal(request.auth.userId, request.body));
  });

  return router;
}
