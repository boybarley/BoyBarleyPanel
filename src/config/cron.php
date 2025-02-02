<?php
return [
    // Daily tasks
    'daily' => [
        [
            'command' => 'backup:database',
            'time' => '00:00'
        ],
        [
            'command' => 'cleanup:logs',
            'time' => '01:00'
        ]
    ],
    
    // Weekly tasks
    'weekly' => [
        [
            'command' => 'backup:system',
            'time' => 'sunday 00:00'
        ]
    ],
    
    // Monthly tasks
    'monthly' => [
        [
            'command' => 'maintenance:full',
            'time' => '1 00:00'
        ]
    ]
];
