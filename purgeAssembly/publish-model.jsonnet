local nodeBoxesPerSector = 14;
local segmentsPerSector = 82;
local nodeBoxes = std.range(1, nodeBoxesPerSector);
local sectors = [ "A","B","C","D","E","F" ];
local segments = std.range(1, segmentsPerSector);


// Defines a function to add a parameter for a node box RIO value
local powerFunc() = {
    name: 'pressurePowerState',
    description: |||
        Pressure power state as an 84 character string. Each character can be one of enum: [E, U, P, N]
        with E=error, U=unavailable, P=power, N=no power. If RIO sampling fails, the value will be E or U]. Char 0 of the string is node box AN1, char 84 is FN14.
    |||,
    type: "string",
};

// Defines a function to add a parameter for a node box RIO value
local nodeFunc(sectorName, nodeName) = {
    local nodeBoxName = sectorName + "N" + nodeName,
    name: nodeBoxName,
    description: 'Pressure value for node box: ' + nodeBoxName + '.',
    type: 'double',
    units: 'psi'
};

// Defines a function to add a parameter for a segment air flow value
local segmentFunc(sectorName, segmentNumber) = {
    local segmentName = sectorName + segmentNumber,
    name: segmentName,
    description: 'Flow value for segment: ' + segmentName + '.',
    type: 'double',
    units: 'lpm'
};

// Creates an array of all the parameters
local addNodeParams() =
    local powerString = [powerFunc()];
    local one = [nodeFunc(s, x) for s in sectors for x in nodeBoxes];
    local two = [segmentFunc(s, x) for s in sectors for x in segments];
    local all = powerString + one + two;
    all;

{
    subsystem: 'M1CS',
    component: 'purgeAssembly',
    publish: {
        events: [
            {
                name: 'status',
                description: |||
                    Purge system state. Published every 100 seconds.
                    The overall state of the M1 Purge system ss reurned. If not within range, the node boxes that are out of range are included.
                |||,
                category: 'STATUS',
                maxRate: 0.01,
                archive: false,
                parameters: [
                    {
                        name: 'assemblyState',
                        description: "The current Assembly state.",
                        enum: ["READY", "FAULTED"]
                    },
                    {
                        name: 'nodeBoxRioHcdState',
                        description: "The current operational state of the node box RIO HCD that is used for node box power and current values.",
                        enum: ["UNINITIALIZED", "READY", "FAULTED"]
                    },
                    {
                        name: 'segmentHcdState',
                        description: |||
                           The current operational state of the segment HCD that is used for segment flow values.
                        |||,
                        enum: ["UNINITIALIZED", "READY", "FAULTED"]
                    },
                    powerFunc(),
                    {
                        name: "flowState",
                        description: |||
                            flowState indicates if all flow values are within range.
                        |||,
                        enum: ["GREEN", "RED"]
                    },
                    {
                        name: "pressureState",
                        description: |||
                            pressureState indicates if all pressure values are within range.
                        |||,
                        enum: ["GREEN", "RED"]
                    },
                    {
                        name: 'averageNodePressure',
                        description: "The average of all node box pressure values. Unit is Pounds Per Square Inch (PSI).",
                        type: "double",
                        units: "psi"
                    },
                    {
                        name: 'maxNodePressure',
                        description: "The largest of all node box pressure values. Unit is Pounds Per Square Inch (PSI).",
                        type: "double",
                        units: "psi"
                    },
                     {
                        name: 'minNodePressure',
                        description: "The smallest of all node box pressure values. Unit is Pounds Per Square Inch (PSI).",
                        type: "double",
                        units: "psi"
                    },
                    {
                        name: 'averageSegmentFlow',
                        description: "The average of all segment flow values. Unit is Liters Per Minute (LPM).",
                        type: "double",
                        units: "lpm"
                    },
                     {
                        name: 'maxSegmentFlow',
                        description: "The largest of all segment flow values. Unit is Liters Per Minute (LPM).",
                        type: "double",
                        units: "lpm"
                    },
                     {
                        name: 'minSegmentFlow',
                        description: "The smallest of all segment flow values. Unit is Liters Per Minute (LPM).",
                        type: "double",
                        units: "lpm"
                    },
                    {
                        name: 'faultedNodes',
                        description: |||
                            If the system is faulted, this parameter is a list of all nodes with out of range values.

                            Example format: "AN3, CN4, EN5".
                        |||,
                        type: "string"
                    }
                ]
            },
            {
                name: 'archiveState',
                description: |||
                     The overall state of the M1 Purge system is published with each pressure and air flow value primarily for DMS.ENG.
                     This event is published every 300 seconds.
                |||,
                category: 'STATUS',
                maxRate: 0.025,
                archive: true,
                parameters: addNodeParams()
            }
        ]
     }
}
