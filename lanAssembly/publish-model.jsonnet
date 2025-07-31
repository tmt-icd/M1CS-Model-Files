local nodeBoxesPerSector = 14;
local segmentsPerSector = 82;
local nodeBoxes = std.range(1, nodeBoxesPerSector);
local sectors = [ "A","B","C","D","E","F" ];
local segments = std.range(1, segmentsPerSector);

// Defines a function to add a parameter for segment availability
local availabilityFunc() = {
    name: 'segmentAvailability',
     description: |||
        Segment availability is a 492 character string, one character for each segment/LSEB. Each character can be one of enum: [A, E, U]
        with A=available, Error=error, U=unavailable. If sampling fails, the value will be E or U]. Char 0 of the string is A1, char 491 is F82.
    |||,
    type: "string",
};

// Defines a function to add a parameter for a segment latency value
local latencyFunc(sectorName, segmentNumber) = {
    local segmentName = sectorName + segmentNumber,
    name: segmentName,
    description: 'Latency value for segment: ' + segmentName + '.',
    type: "double",
    units: "millisecond"
};

// Creates an array of all the parameters
local addParams() =
    local latencies = [latencyFunc(s, x) for s in sectors for x in segments];
    local availabilityString = [availabilityFunc()];
    local all = availabilityString + latencies;
    all;

{
    subsystem: 'M1CS',
    component: 'lanAssembly',
    publish: {
        events: [
            {
                name: 'status',
                description: |||
                    LAN system state. Published every eventPeriod seconds or when an issue is detected during sampling.
                    The overall state of the M1LAN system is published.
                |||,
                category: 'STATUS',
                maxRate: 0.0006,
                archive: false,
                parameters: [
                    {
                        name: 'assemblyState',
                        description: "The current operational state of the LAN Assembly.",
                        enum: ["READY", "FAULTED"]
                    },
                    {
                        name: 'lanHcdState',
                        description: "The current operational state of the LAN HCD that is used to sample latency and availability values.",
                        enum: ["UNINITIALIZED", "READY", "FAULTED"]
                    },
                    {
                        name: 'segmentAvailability',
                        description: |||
                            Segment availability is a 492 character string, one character for each segment/LSEB. Each character can be one of enum: [A, E, U]
                            with A=available, Error=error, U=unavailable. If sampling fails, the value will be E or U]. Char 0 of the string is A1, char 491 is F82.
                        |||,
                        type: "string",
                    },
                    {
                        name: 'segmentLatency',
                        description: |||
                            Segment latency is a 492 character string, one character for each segment/LSEB. Each character can be one of enum: [G, R, U]
                            with G=green - within limit, R=red - outside of limit, U=unavailable. If sampling fails, the value will be U]. Char 0 of the string is A1, char 491 is F82.
                        |||,
                        type: "string",
                    },
                    {
                        name: "lanState",
                        description: |||
                            Overall LAN state indicates whether all latency values for available segments are within limits.
                        |||,
                        enum: ["GREEN", "RED"]
                    },
                    {
                        name: 'averageSegmentLatency',
                        description: "The average of all recent segment latency values.",
                        type: "double",
                        units: "millisecond"
                    },
                    {
                        name: 'maxSegmentLatency',
                        description: "The largest of all recent segment latency values.",
                        type: "double",
                        units: "millisecond"
                    },
                     {
                        name: 'minSegmentlatency',
                        description: "The smallest of all recent segment latency values.",
                        type: "double",
                        units: "millisecond"
                    }
                ]
            },
            {
                name: 'archiveState',
                description: |||
                     The overall state of the M1CS LAN is published with each latency value. Primarily for DMS.ENG.
                     This event is published every eventPeriod or when an issue is discovered. Default is every 30 minutes.
                |||,
                category: 'STATUS',
                maxRate: 0.0006,
                archive: true,
                parameters:
                    addParams()

            }
        ]
     }
}
