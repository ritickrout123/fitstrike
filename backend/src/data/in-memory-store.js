import { hashPassword } from '../lib/security.js';

export function createInMemoryStore() {
  function createSeededToday() {
    return {
      date: '2026-03-25',
      streak: 14,
      workout: {
        label: 'Push Day',
        focus: 'Chest · Shoulders · Triceps',
        exercises: [
          {
            id: 'barbell-bench-press',
            name: 'Barbell Bench Press',
            targetSets: 4,
            repRange: '6-8',
            loadKg: 82.5,
            restSeconds: 120,
            isCompleted: true
          },
          {
            id: 'incline-dumbbell-press',
            name: 'Incline Dumbbell Press',
            targetSets: 3,
            repRange: '8-10',
            loadKg: 30,
            restSeconds: 90,
            isCompleted: true
          },
          {
            id: 'seated-shoulder-press',
            name: 'Seated Shoulder Press',
            targetSets: 3,
            repRange: '8-10',
            loadKg: 24,
            restSeconds: 90,
            isCompleted: false
          },
          {
            id: 'cable-lateral-raise',
            name: 'Cable Lateral Raise',
            targetSets: 3,
            repRange: '12-15',
            loadKg: 9,
            restSeconds: 60,
            isCompleted: false
          },
          {
            id: 'tricep-rope-pushdown',
            name: 'Tricep Rope Pushdown',
            targetSets: 3,
            repRange: '10-12',
            loadKg: 32,
            restSeconds: 60,
            isCompleted: false
          },
          {
            id: 'overhead-tricep-extension',
            name: 'Overhead Tricep Extension',
            targetSets: 2,
            repRange: '12-15',
            loadKg: 26,
            restSeconds: 60,
            isCompleted: false
          }
        ],
        completedAt: null
      },
      nutrition: {
        caloriesGoal: 2900,
        macros: {
          protein: { goal: 180 },
          carbs: { goal: 280 },
          fats: { goal: 70 }
        },
        meals: [
          {
            id: 'meal_breakfast_oats',
            category: 'Breakfast',
            name: 'Overnight Oats + Whey',
            calories: 520,
            protein: 42,
            carbs: 63,
            fats: 12,
            timeLabel: '08:10'
          },
          {
            id: 'meal_lunch_bowl',
            category: 'Lunch',
            name: 'Chicken Rice Bowl',
            calories: 680,
            protein: 54,
            carbs: 78,
            fats: 18,
            timeLabel: '13:20'
          },
          {
            id: 'meal_snack_yogurt',
            category: 'Snack',
            name: 'Greek Yogurt + Fruit',
            calories: 240,
            protein: 20,
            carbs: 28,
            fats: 4,
            timeLabel: '16:00'
          },
          {
            id: 'meal_post_lift_shake',
            category: 'Post Lift',
            name: 'Mass Gainer Shake',
            calories: 300,
            protein: 12,
            carbs: 26,
            fats: 14,
            timeLabel: '18:10'
          }
        ]
      },
      missions: [
        { id: 'run-5k', label: 'Daily 5K Sprint', progress: 0.48, reward: 500 },
        { id: 'capture-3', label: 'Capture 3 Zones', progress: 0.66, reward: 300 }
      ]
    };
  }

  const seededUser = {
    id: 'user_riley_kane',
    username: 'striker_01',
    email: 'striker@fitstrike.gg',
    passwordHash: hashPassword('fitstrike123'),
    profile: {
      displayName: 'Riley Kane',
      level: 24,
      title: 'Striker'
    },
    social: {
      clanId: 'clan_iron_wolves'
    },
    stats: {
      totalDistance: 124200,
      totalArea: 150000000,
      workoutsCompleted: 42,
      territoryCaptures: 86
    },
    today: createSeededToday()
  };

  const supportingUsers = [
    {
      id: 'user_sarah_j',
      username: 'sarahj_fit',
      email: 'sarah@fitstrike.gg',
      passwordHash: hashPassword('supporting-user'),
      profile: {
        displayName: 'Sarah J.',
        level: 50,
        title: 'Elite Raider'
      },
      social: {
        clanId: 'clan_iron_wolves'
      },
      stats: {
        totalDistance: 198300,
        totalArea: 284000000,
        workoutsCompleted: 74,
        territoryCaptures: 132
      },
      today: createSeededToday()
    },
    {
      id: 'user_wolfking',
      username: 'wolfking',
      email: 'wolf@fitstrike.gg',
      passwordHash: hashPassword('supporting-user'),
      profile: {
        displayName: 'WolfKing',
        level: 62,
        title: 'Zone Breaker'
      },
      social: {
        clanId: 'clan_iron_wolves'
      },
      stats: {
        totalDistance: 240500,
        totalArea: 315000000,
        workoutsCompleted: 103,
        territoryCaptures: 180
      },
      today: createSeededToday()
    },
    {
      id: 'user_mike_c',
      username: 'mikec',
      email: 'mike@fitstrike.gg',
      passwordHash: hashPassword('supporting-user'),
      profile: {
        displayName: 'Mike C.',
        level: 58,
        title: 'Champion'
      },
      social: {
        clanId: null
      },
      stats: {
        totalDistance: 281400,
        totalArea: 342000000,
        workoutsCompleted: 88,
        territoryCaptures: 163
      },
      today: createSeededToday()
    },
    {
      id: 'user_alex_m',
      username: 'alexm',
      email: 'alex@fitstrike.gg',
      passwordHash: hashPassword('supporting-user'),
      profile: {
        displayName: 'Alex M.',
        level: 41,
        title: 'Runner'
      },
      social: {
        clanId: null
      },
      stats: {
        totalDistance: 154200,
        totalArea: 182000000,
        workoutsCompleted: 47,
        territoryCaptures: 90
      },
      today: createSeededToday()
    }
  ];

  const users = new Map([[seededUser.id, seededUser]]);
  for (const user of supportingUsers) {
    users.set(user.id, user);
  }

  const clans = new Map([
    [
      'clan_iron_wolves',
      {
        id: 'clan_iron_wolves',
        name: 'Iron Wolves',
        tag: 'IWLF',
        level: 14,
        rank: 8,
        memberCount: 42,
        maxMembers: 50,
        war: {
          title: 'Weekly Territory War',
          status: 'Matches found: 4 clans',
          xpBoost: '1.5x XP Boost'
        },
        roster: [
          {
            userId: 'user_riley_kane',
            role: 'Leader',
            contribution: '+12.4k',
            status: 'Active Now'
          },
          {
            userId: 'user_sarah_j',
            role: 'Co-Leader',
            contribution: '+8.8k',
            status: 'In Training'
          },
          {
            userId: 'user_wolfking',
            role: 'Elder',
            contribution: '+15.2k',
            status: 'Capturing Zone'
          }
        ]
      }
    ]
  ]);

  const territories = [
    {
      id: 'territory_a',
      ownerId: 'user_riley_kane',
      ownerName: 'You',
      area: 4500000,
      center: { lat: 30.905, lng: 75.858 },
      color: '#C8FF00',
      isOwnedByCurrentUser: true
    },
    {
      id: 'territory_b',
      ownerId: 'user_riley_kane',
      ownerName: 'You',
      area: 1200000,
      center: { lat: 30.895, lng: 75.842 },
      color: '#C8FF00',
      isOwnedByCurrentUser: true
    },
    {
      id: 'territory_c',
      ownerId: 'user_alex_m',
      ownerName: 'Alex M.',
      area: 1800000,
      center: { lat: 30.912, lng: 75.865 },
      color: '#00E5FF',
      isOwnedByCurrentUser: false
    },
    {
      id: 'territory_d',
      ownerId: 'user_mike_c',
      ownerName: 'Mike C.',
      area: 2100000,
      center: { lat: 30.888, lng: 75.855 },
      color: '#FF3D71',
      isOwnedByCurrentUser: false
    }
  ];

  const leaderboards = {
    global: [
      {
        userId: 'user_mike_c',
        rank: 1,
        displayName: 'Mike C.',
        level: 58,
        title: 'Champion',
        scoreKm2: 342
      },
      {
        userId: 'user_sarah_j',
        rank: 2,
        displayName: 'Sarah J.',
        level: 50,
        title: 'Elite Raider',
        scoreKm2: 284
      },
      {
        userId: 'user_wolfking',
        rank: 3,
        displayName: 'WolfKing',
        level: 62,
        title: 'Zone Breaker',
        scoreKm2: 210
      },
      {
        userId: 'user_alex_m',
        rank: 4,
        displayName: 'Alex M.',
        level: 41,
        title: 'Runner',
        scoreKm2: 182
      },
      {
        userId: 'user_riley_kane',
        rank: 6,
        displayName: 'You',
        level: 24,
        title: 'Striker',
        scoreKm2: 150
      }
    ]
  };

  const channels = [
    {
      id: 'global',
      type: 'global',
      name: 'Global',
      unreadCount: 2,
      preview: 'Anyone hitting the downtown gym for the 2x XP event?'
    },
    {
      id: 'clan:iron_wolves',
      type: 'clan',
      name: 'Iron Wolves',
      unreadCount: 1,
      preview: 'Clan war starts in 12 hours.'
    },
    {
      id: 'local:downtown',
      type: 'local',
      name: 'Downtown',
      unreadCount: 0,
      preview: 'Barely a drizzle. Perfect tempo weather actually.'
    }
  ];

  const channelMessages = new Map([
    [
      'global',
      [
        {
          id: 'msg_global_1',
          senderId: 'user_mike_c',
          type: 'text',
          content: 'Anyone hitting the downtown gym for the 2x XP event?',
          timestamp: '2026-03-25T17:10:00.000Z'
        },
        {
          id: 'msg_global_2',
          senderId: 'user_alex_m',
          type: 'text',
          content: 'I will be there in 20 mins. Let us form a squad to capture the central zone.',
          timestamp: '2026-03-25T17:12:00.000Z'
        },
        {
          id: 'msg_global_3',
          senderId: null,
          type: 'system',
          content: "IRON WOLVES CAPTURED 'NORTH PARK'",
          timestamp: '2026-03-25T17:14:00.000Z'
        }
      ]
    ],
    [
      'clan:iron_wolves',
      [
        {
          id: 'msg_clan_1',
          senderId: null,
          type: 'system',
          content: 'CLAN WAR STARTS IN 12 HOURS',
          timestamp: '2026-03-25T17:00:00.000Z'
        },
        {
          id: 'msg_clan_2',
          senderId: 'user_wolfking',
          type: 'text',
          content: 'Make sure your energy is full before 8 PM tonight.',
          timestamp: '2026-03-25T17:02:00.000Z'
        },
        {
          id: 'msg_clan_3',
          senderId: 'user_riley_kane',
          type: 'text',
          content: 'I am ready. Let us dominate this week.',
          timestamp: '2026-03-25T17:03:00.000Z'
        }
      ]
    ],
    [
      'local:downtown',
      [
        {
          id: 'msg_local_1',
          senderId: null,
          type: 'system',
          content: "YOU JOINED THE 'DOWNTOWN' COMMS",
          timestamp: '2026-03-25T16:45:00.000Z'
        },
        {
          id: 'msg_local_2',
          senderId: 'user_sarah_j',
          type: 'text',
          content: 'Is it still raining in the park area?',
          timestamp: '2026-03-25T16:47:00.000Z'
        },
        {
          id: 'msg_local_3',
          senderId: 'user_alex_m',
          type: 'text',
          content: 'Barely a drizzle. Perfect tempo weather actually.',
          timestamp: '2026-03-25T16:49:00.000Z'
        }
      ]
    ]
  ]);

  const events = [
    {
      id: 'flash-double-xp',
      type: 'flash',
      status: 'active',
      title: 'Flash: Double XP',
      subtitle: 'Global server-wide effect',
      rewardTag: 'LIVE',
      participantIds: ['user_riley_kane']
    },
    {
      id: 'evening-blitz',
      type: 'daily',
      status: 'upcoming',
      title: 'Evening Blitz',
      subtitle: 'Bonus territory multipliers',
      rewardTag: '+150 PTS',
      participantIds: []
    },
    {
      id: 'clan-boss-raid',
      type: 'raid',
      status: 'upcoming',
      title: 'Clan Boss Raid',
      subtitle: 'Mecha-Titan Event',
      rewardTag: 'EPIC LOOT',
      participantIds: []
    }
  ];

  return {
    users,
    clans,
    territories,
    leaderboards,
    channels,
    channelMessages,
    events,
    sessions: new Map()
  };
}
