local nodeBoxesPerSector = 14;
local segmentsPerSector = 82;
local nodeBoxes = std.range(1, nodeBoxesPerSector);
local sectors = [ "A","B","C","D","E","F" ];
local segments = std.range(1, segmentsPerSector);

// Defines a function to add a parameter for a node box RIO value
local powerFunc() = {
    name: 'powerState',
    description: |||
        Mirror power state as a 492 character string. Each character can be one of enum: [E, U, P, N]
        with E=error, U=unavailable, P=power, N=no power. If RIO sampling fails, the value will be E or U]. Char 0 of the string is A1, char 491 is F82.
    |||,
    type: "string",
};

// Defines a function to add a parameter for a segment current value
local segmentFunc(sectorName, segmentNumber) = {
    local segmentName = sectorName + segmentNumber,
    name: segmentName,
    description: 'Current value for segment: ' + segmentName + '.',
    type: "double",
    units: "ampere"
};

// Creates an array of all the parameters
local addParams() =

    local currents = [segmentFunc(s, x) for s in sectors for x in segments];
    local powerString = [powerFunc()];
    local all = powerString + currents;
    all;

{
    subsystem: 'M1CS',
    component: 'powerAssembly',
    publish: {
        events: [
            {
                name: 'status',
                description: |||
                    Power system state. Published every 900 seconds - 4 times/hour or when a segment is turned on or off.
                    The overall state of the M1 Power system is published. If not within range, the node boxes with values that are out of range are included.
                |||,
                category: 'STATUS',
                maxRate: 0.001,
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
                        name: 'powerState',
                        description: |||
                            Mirror power state as a 492 character string. Each character can be one of enum: [E, U, P, N]
                            with E=error, U=unavailable, P=power, N=no power. If RIO sampling fails, the value will be E or U]. Char 0 of the string is A1, char 491 is F82.
                        |||,
                        type: "string",
                    },
                    {
                        name: "currentState",
                        description: |||
                            Overall state indicates if all segment current values are within range.
                        |||,
                        enum: ["GREEN", "RED"]
                    },
                    {
                        name: 'averageSegmentCurrent',
                        description: "The average of all node box current values.",
                        type: "double",
                        units: "ampere"
                    },
                    {
                        name: 'maxSegmentCurrent',
                        description: "The largest of all node box current values.",
                        type: "double",
                        units: "ampere"
                    },
                     {
                        name: 'minSegmentCurrent',
                        description: "The smallest of all node box current values.",
                        type: "double",
                        units: "ampere"
                    },
                    {
                        name: 'faultedNodes',
                        description: |||
                            If the system is faulted, this parameter is a list of all nodes with out of range current values.

                            Example format: "EN3, AN4, FN5".
                        |||,
                        type: "string"
                    }
                ]
            },
            {
                name: 'archiveState',
                description: |||
                     The overall state of the M1 Power system is published with each current value primarily for DMS.ENG.
                     This event is published every 900 seconds/15 minutes.
                |||,
                category: 'STATUS',
                maxRate: 0.001,
                archive: true,
                parameters:
                    addParams()

            }
        ]
     }
}
