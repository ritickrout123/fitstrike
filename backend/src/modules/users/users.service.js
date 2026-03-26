import { HttpError } from '../../lib/http-error.js';

export function createUserService(store) {
  function getUserEntity(userId) {
    const user = store.users.get(userId);

    if (!user) {
      throw new HttpError(404, 'USER_NOT_FOUND', 'User could not be found.');
    }

    return user;
  }

  function summarizeWorkout(workout) {
    const exerciseCount = workout.exercises.length;
    const completedExerciseCount = workout.exercises.filter((exercise) => exercise.isCompleted).length;

    return {
      label: workout.label,
      focus: workout.focus,
      exerciseCount,
      completedExerciseCount,
      isComplete: completedExerciseCount === exerciseCount && exerciseCount > 0
    };
  }

  function summarizeNutrition(nutrition) {
    const consumed = nutrition.meals.reduce(
      (totals, meal) => ({
        calories: totals.calories + meal.calories,
        protein: totals.protein + meal.protein,
        carbs: totals.carbs + meal.carbs,
        fats: totals.fats + meal.fats
      }),
      { calories: 0, protein: 0, carbs: 0, fats: 0 }
    );

    return {
      caloriesConsumed: consumed.calories,
      caloriesGoal: nutrition.caloriesGoal,
      mealCount: nutrition.meals.length,
      macros: {
        protein: {
          consumed: consumed.protein,
          goal: nutrition.macros.protein.goal
        },
        carbs: {
          consumed: consumed.carbs,
          goal: nutrition.macros.carbs.goal
        },
        fats: {
          consumed: consumed.fats,
          goal: nutrition.macros.fats.goal
        }
      },
      meals: nutrition.meals.map((meal) => ({ ...meal }))
    };
  }

  function toGymPlan(today) {
    const workout = summarizeWorkout(today.workout);

    return {
      date: today.date,
      ...workout,
      exercises: today.workout.exercises.map((exercise) => ({ ...exercise }))
    };
  }

  function toNutritionSnapshot(today) {
    const nutrition = summarizeNutrition(today.nutrition);

    return {
      date: today.date,
      ...nutrition
    };
  }

  function toPublicUser(user) {
    return {
      id: user.id,
      username: user.username,
      email: user.email,
      profile: {
        displayName: user.profile.displayName,
        level: user.profile.level,
        title: user.profile.title
      },
      stats: {
        totalDistance: user.stats.totalDistance,
        totalArea: user.stats.totalArea,
        workoutsCompleted: user.stats.workoutsCompleted,
        territoryCaptures: user.stats.territoryCaptures
      },
      streak: user.today.streak
    };
  }

  function getPublicUser(userId) {
    return toPublicUser(getUserEntity(userId));
  }

  function getTodaySnapshot(userId) {
    const today = getUserEntity(userId).today;
    const workout = summarizeWorkout(today.workout);
    const nutrition = summarizeNutrition(today.nutrition);

    return {
      date: today.date,
      streak: today.streak,
      workout: {
        label: workout.label,
        focus: workout.focus,
        exerciseCount: workout.exerciseCount,
        completedExerciseCount: workout.completedExerciseCount,
        isComplete: workout.isComplete
      },
      nutrition: {
        caloriesConsumed: nutrition.caloriesConsumed,
        caloriesGoal: nutrition.caloriesGoal,
        mealCount: nutrition.mealCount,
        macros: {
          protein: { ...nutrition.macros.protein },
          carbs: { ...nutrition.macros.carbs },
          fats: { ...nutrition.macros.fats }
        }
      },
      missions: today.missions.map((mission) => ({
        ...mission
      }))
    };
  }

  function getGymPlan(userId) {
    return toGymPlan(getUserEntity(userId).today);
  }

  function completeGymExercise(userId, exerciseId) {
    const user = getUserEntity(userId);
    const exercise = user.today.workout.exercises.find((entry) => entry.id === exerciseId);

    if (!exercise) {
      throw new HttpError(404, 'EXERCISE_NOT_FOUND', 'Exercise could not be found.');
    }

    const wasCompleted = exercise.isCompleted;
    if (!wasCompleted) {
      exercise.isCompleted = true;
    }

    const workout = summarizeWorkout(user.today.workout);
    const wasWorkoutAlreadyComplete = Boolean(user.today.workout.completedAt);

    if (workout.isComplete && !wasWorkoutAlreadyComplete) {
      user.today.workout.completedAt = new Date().toISOString();
      user.stats.workoutsCompleted += 1;
    }

    return {
      exerciseId,
      wasAlreadyCompleted: wasCompleted,
      workout,
      workoutsCompleted: user.stats.workoutsCompleted
    };
  }

  function getNutrition(userId) {
    return toNutritionSnapshot(getUserEntity(userId).today);
  }

  function parseInteger(value, { field, min = 0 } = {}) {
    const parsed = Number.parseInt(String(value ?? ''), 10);

    if (!Number.isFinite(parsed) || parsed < min) {
      throw new HttpError(
        400,
        'INVALID_INPUT',
        `${field ?? 'Value'} must be an integer greater than or equal to ${min}.`
      );
    }

    return parsed;
  }

  function addNutritionMeal(userId, input = {}) {
    const user = getUserEntity(userId);
    const name = String(input.name ?? '').trim();
    const category = String(input.category ?? 'Quick Add').trim() || 'Quick Add';

    if (name.length < 2) {
      throw new HttpError(400, 'INVALID_INPUT', 'Meal name must be at least 2 characters long.');
    }

    const meal = {
      id: `meal_${Date.now()}`,
      category,
      name,
      calories: parseInteger(input.calories, { field: 'Calories', min: 1 }),
      protein: parseInteger(input.protein, { field: 'Protein' }),
      carbs: parseInteger(input.carbs, { field: 'Carbs' }),
      fats: parseInteger(input.fats, { field: 'Fats' }),
      timeLabel: String(input.timeLabel ?? 'Now')
    };

    user.today.nutrition.meals.push(meal);

    return {
      meal: { ...meal },
      nutrition: toNutritionSnapshot(user.today)
    };
  }

  return {
    addNutritionMeal,
    completeGymExercise,
    getGymPlan,
    getNutrition,
    getPublicUser,
    getTodaySnapshot,
    toPublicUser
  };
}
