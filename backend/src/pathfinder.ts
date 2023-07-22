export const findOptimalPath = (dexA: AMMState, dexB: AMMState, trade: Trade): string => { 
    return `${dexA} ${dexB} ${trade}`
}