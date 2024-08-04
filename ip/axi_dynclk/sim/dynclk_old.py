from dataclasses import dataclass


CLK_BIT_WEDGE = (13)
CLK_BIT_NOCOUNT = (12)

# /* This value is used to signal an error */
ERR_CLKCOUNTCALC = (0xFFFFFFFF)
ERR_CLKDIVIDER = ((1) << CLK_BIT_WEDGE | (1) << CLK_BIT_NOCOUNT)

@dataclass
class ClkConfig:
    clk0L : int = 0
    clkFBL : int = 0
    clkFBH_clk0H : int = 0
    divclk : int = 0
    lockL : int = 0
    fltr_lockH : int = 0


@dataclass
class ClkMode:
    freq : int = 0
    fbmult : int = 0
    clkdiv : int = 0
    maindiv : int = 0


lock_lookup = [
    0b0011000110111110100011111010010000000001,
    0b0011000110111110100011111010010000000001,
    0b0100001000111110100011111010010000000001,
    0b0101101011111110100011111010010000000001,
    0b0111001110111110100011111010010000000001,
    0b1000110001111110100011111010010000000001,
    0b1001110011111110100011111010010000000001,
    0b1011010110111110100011111010010000000001,
    0b1100111001111110100011111010010000000001,
    0b1110011100111110100011111010010000000001,
    0b1111111111111000010011111010010000000001,
    0b1111111111110011100111111010010000000001,
    0b1111111111101110111011111010010000000001,
    0b1111111111101011110011111010010000000001,
    0b1111111111101000101011111010010000000001,
    0b1111111111100111000111111010010000000001,
    0b1111111111100011111111111010010000000001,
    0b1111111111100010011011111010010000000001,
    0b1111111111100000110111111010010000000001,
    0b1111111111011111010011111010010000000001,
    0b1111111111011101101111111010010000000001,
    0b1111111111011100001011111010010000000001,
    0b1111111111011010100111111010010000000001,
    0b1111111111011001000011111010010000000001,
    0b1111111111011001000011111010010000000001,
    0b1111111111010111011111111010010000000001,
    0b1111111111010101111011111010010000000001,
    0b1111111111010101111011111010010000000001,
    0b1111111111010100010111111010010000000001,
    0b1111111111010100010111111010010000000001,
    0b1111111111010010110011111010010000000001,
    0b1111111111010010110011111010010000000001,
    0b1111111111010010110011111010010000000001,
    0b1111111111010001001111111010010000000001,
    0b1111111111010001001111111010010000000001,
    0b1111111111010001001111111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001,
    0b1111111111001111101011111010010000000001
]

filter_lookup_low = [
    0b0001011111,
    0b0001010111,
    0b0001111011,
    0b0001011011,
    0b0001101011,
    0b0001110011,
    0b0001110011,
    0b0001110011,
    0b0001110011,
    0b0001001011,
    0b0001001011,
    0b0001001011,
    0b0010110011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001010011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0001100011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010010011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011,
    0b0010100011
]

def ClkDivider(divide: int) -> int:
    output : int = 0
    highTime : int = 0
    lowTime : int = 0

    if ((divide < 1) | (divide > 128)):
        return ERR_CLKDIVIDER

    if (divide == 1):
        return 0x1041

    highTime = divide // 2
    if (divide & 0b1): # if divide is odd
        lowTime = highTime + 1
        output = 1 << CLK_BIT_WEDGE
    else:
        lowTime = highTime

    output |= 0x03F & lowTime
    output |= 0xFC0 & (highTime << 6)
    return output



def ClkCountCalc( divide: int) -> int:
    output : int = 0
    divCalc : int = 0

    divCalc = ClkDivider(divide)
    if (divCalc == ERR_CLKDIVIDER):
        output = ERR_CLKCOUNTCALC
    else:
        output = (0xFFF & divCalc) | ((divCalc << 10) & 0x00C00000)
    return output


def ClkFindReg (clkParams: ClkMode) -> ClkConfig:

    regValues = ClkConfig()

    if ((clkParams.fbmult < 2) | clkParams.fbmult > 64 ):
        return None

    regValues.clk0L = ClkCountCalc(clkParams.clkdiv)
    if (regValues.clk0L == ERR_CLKCOUNTCALC):
        return None

    regValues.clkFBL = ClkCountCalc(clkParams.fbmult)
    if (regValues.clkFBL == ERR_CLKCOUNTCALC):
        return None

    regValues.clkFBH_clk0H = 0

    regValues.divclk = ClkDivider(clkParams.maindiv)
    if (regValues.divclk == ERR_CLKDIVIDER):
        return None

    regValues.lockL = (lock_lookup[clkParams.fbmult - 1] & 0xFFFFFFFF)

    regValues.fltr_lockH = ((lock_lookup[clkParams.fbmult - 1] >> 32) & 0x000000FF)
    regValues.fltr_lockH |= ((filter_lookup_low[clkParams.fbmult - 1] << 16) & 0x03FF0000)

    return regValues



def ClkFindParams(freq: float) -> ClkMode:

    bestPick = ClkMode() # return value

    bestError = 2000.0
    curError = float(0)
    curClkMult = float(0)
    curFreq = float(0)
    curDiv : int = 0
    curFb : int = 0
    curClkDiv : int = 0
    minFb = 0
    maxFb = 0

    # /*
    #  * This is necessary because the MMCM actual is generating 5x the desired pixel clock, and that
    #  * clock is then run through a BUFR that divides it by 5 to generate the pixel clock. Note this
    #  * means the pixel clock is on the Regional clock network, not the global clock network. In the
    #  * future if options like these are parameterized in the axi_dynclk core, then this function will
    #  * need to change.
    #  */
    freq = freq * 5.0

    bestPick.freq = 0.0
    # /*
    # * TODO: replace with a smarter algorithm that doesn't doesn't check every possible combination
    # */
    for curDiv in range(1, 11):
        minFb = curDiv * 6 # This accounts for the 100MHz input and the 600MHz minimum VCO
        maxFb = curDiv * 12 # This accounts for the 100MHz input and the 1200MHz maximum VCO
        if (maxFb > 64):
            maxFb = 64

        curClkMult = (100.0 / curDiv) / freq # This multiplier is used to find the best clkDiv value for each FB value

        curFb = minFb
        while (curFb <= maxFb):
            curClkDiv = int((curClkMult * curFb) + 0.5)
            curFreq = ((100.0 /  curDiv) / curClkDiv) * curFb
            curError = abs(curFreq - freq)
            if (curError < bestError):
                bestError = curError
                bestPick.clkdiv = curClkDiv
                bestPick.fbmult = curFb
                bestPick.maindiv = curDiv
                bestPick.freq = curFreq

            curFb += 1

    # /*
    #  * We want the ClkMode struct and errors to be based on the desired frequency. Need to check this doesn't introduce
    #  * rounding errors.
    #  */
    bestPick.freq = bestPick.freq / 5.0
    bestError = bestError / 5.0

    return bestPick


clkMode = ClkFindParams(33) # actual application
clkReg = ClkFindReg(clkMode)

print(clkMode)
print(clkReg)


print(hex(clkReg.clk0L))
print(hex(clkReg.clkFBL))
print(hex(clkReg.clkFBH_clk0H))
print(hex(clkReg.divclk))
print(hex(clkReg.lockL))
print(hex(clkReg.fltr_lockH))
