from dataclasses import dataclass
import logging as log

# Register Map
DDYNCLK_CTRL         = 0x0
DDYNCLK_STATUS       = 0x4
DDYNCLK_CLK_L        = 0x8
DDYNCLK_FB_L         = 0x0C
DDYNCLK_FB_H_CLK_H   = 0x10
DDYNCLK_DIV          = 0x14
DDYNCLK_LOCK_L       = 0x18
DDYNCLK_FLTR_LOCK_H  = 0x1C
DDYNCLK_REF_CLK_FREQ = 0x20

################################################################


# /* Back-ported from Linux driver */
DIV_ROUND_UP = lambda n, d : (((n) + (d) - 1) // (d))

CLK_BIT_WEDGE = (13)
CLK_BIT_NOCOUNT = (12)

# /* This value is used to signal an error */
ERR_CLKCOUNTCALC = (0xFFFFFFFF)
ERR_CLKDIVIDER = ((1) << CLK_BIT_WEDGE | (1) << CLK_BIT_NOCOUNT)

DYNCLK_DIV_1_REGMASK = (0x1041)
# /* 25 MHz (125 KHz / 5) */
DYNCLK_DEFAULT_FREQ = 125000

MMCM_FREQ_VCOMIN = (600000)
MMCM_FREQ_VCOMAX = (1200000)
MMCM_FREQ_PFDMIN = (10000)
MMCM_FREQ_PFDMAX = (450000)
MMCM_FREQ_OUTMIN = (4000)
MMCM_FREQ_OUTMAX = (800000)
MMCM_DIV_MAX = (106)
MMCM_FB_MIN = (2)
MMCM_FB_MAX = (64)
MMCM_CLKDIV_MAX = (128)
MMCM_CLKDIV_MIN = (1)


# /************************** Type Definitions ***************************/
@dataclass
class dglnt_dynclk_reg:
    clk0L : int = 0
    clkFBL : int = 0
    clkFBH_clk0H : int = 0
    divclk : int = 0
    lockL : int = 0
    fltr_lockH : int = 0

@dataclass
class dglnt_dynclk_mode:
    freq : int = 0
    fbmult : int = 0
    clkdiv : int = 0
    maindiv : int = 0


# /************************** Constant Definitions ***************************/
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

# /************************** Function Definitions ***************************/

def dglnt_dynclk_divider(divide: int) -> int:

    output = (0)
    highTime = (0)
    lowTime = (0)

    if ((divide < 1) | (divide > 128)):
        return ERR_CLKDIVIDER

    if (divide == 1):
        return DYNCLK_DIV_1_REGMASK

    highTime = divide // 2
    # /* if divide is odd */
    if (divide & 0x1) :
        lowTime = highTime + 1
        output = 1 << CLK_BIT_WEDGE
    else:
        lowTime = highTime

    output |= 0x03F & lowTime
    output |= 0xFC0 & (highTime << 6)
    return output



def dglnt_dynclk_count_calc(divide: int) -> int:

    output = (0)
    divCalc = (0)

    divCalc = dglnt_dynclk_divider(divide)
    if (divCalc == ERR_CLKDIVIDER):
        output = ERR_CLKCOUNTCALC
    else:
        output = (0xFFF & divCalc) | ((divCalc << 10) & 0x00C00000)
    return output


def dglnt_dynclk_find_reg(clkParams:dglnt_dynclk_mode) -> dglnt_dynclk_reg:

    regValues = dglnt_dynclk_reg()

    if ((clkParams.fbmult < 2) | clkParams.fbmult > 64):
        return None

    regValues.clk0L = dglnt_dynclk_count_calc(clkParams.clkdiv)
    if (regValues.clk0L == ERR_CLKCOUNTCALC):
        return None

    regValues.clkFBL = dglnt_dynclk_count_calc(clkParams.fbmult)
    if (regValues.clkFBL == ERR_CLKCOUNTCALC):
        return None

    regValues.clkFBH_clk0H = 0

    regValues.divclk = dglnt_dynclk_divider(clkParams.maindiv)
    if (regValues.divclk == ERR_CLKDIVIDER):
        return None

    regValues.lockL = (lock_lookup[clkParams.fbmult - 1] & 0xFFFFFFFF)

    regValues.fltr_lockH = ((lock_lookup[clkParams.fbmult - 1] >> 32) & 0x000000FF)
    regValues.fltr_lockH |= ((filter_lookup_low[clkParams.fbmult - 1] << 16) & 0x03FF0000)

    return regValues


###########################################



def dglnt_dynclk_find_mode(freq: int,
                           parentFreq: int) -> dglnt_dynclk_mode:

    bestPick = dglnt_dynclk_mode()

    bestError = MMCM_FREQ_OUTMAX
    minFb = 0
    maxFb = 0
    curDiv = 1
    freq_found = False

    bestPick.freq = 0
    if (parentFreq == 0):
        return None

    # /* minimum frequency is actually dictated by VCOmin */
    if (freq < MMCM_FREQ_OUTMIN):
        freq = MMCM_FREQ_OUTMIN
    if (freq > MMCM_FREQ_OUTMAX):
        freq = MMCM_FREQ_OUTMAX
    log.debug("freq = {}".format(freq))

    if (parentFreq > MMCM_FREQ_PFDMAX):
        curDiv = 2
    log.debug("curDiv = {}".format(curDiv))


    maxDiv = parentFreq // MMCM_FREQ_PFDMIN
    if (maxDiv > MMCM_DIV_MAX):
        maxDiv = MMCM_DIV_MAX
    log.debug("maxDiv = {}".format(maxDiv))

    while (curDiv <= maxDiv and not freq_found):

        log.debug("")
        log.debug("curDiv = {}".format(curDiv))

        minFb = curDiv * DIV_ROUND_UP(MMCM_FREQ_VCOMIN, parentFreq)
        maxFb = curDiv * (MMCM_FREQ_VCOMAX // parentFreq)
        if (maxFb > MMCM_FB_MAX):
            maxFb = MMCM_FB_MAX
        if (minFb < MMCM_FB_MIN):
            minFb = MMCM_FB_MIN

        log.debug("maxFb = {}".format(maxFb))
        log.debug("minFb = {}".format(minFb))

        divVal = curDiv * freq
        
        log.debug("divVal = {}".format(divVal))

        # This multiplier is used to find the best clkDiv value for
        # each FB value
        curClkMult = ((parentFreq * 1000) + (divVal // 2)) // divVal

        log.debug("curClkMult = {}".format(curClkMult))

        curFb = minFb
        while (curFb <= maxFb and not freq_found):

            log.debug("")
            log.debug("curFb = {}".format(curFb))

            curClkDiv = ((curClkMult * curFb) + 500) // 1000
            if (curClkDiv > MMCM_CLKDIV_MAX):
                curClkDiv = MMCM_CLKDIV_MAX
            if (curClkDiv < MMCM_CLKDIV_MIN):
                curClkDiv = MMCM_CLKDIV_MIN

            log.debug("curClkDiv = {}".format(curClkDiv))
            
            curFreq = (((parentFreq * curFb) // curDiv) // curClkDiv)

            log.debug("curFreq = {}".format(curFreq))

            if (curFreq >= freq):
                curError = curFreq - freq
            else:
                curError = freq - curFreq

            log.debug("curError = {}".format(curError))

            if (curError < bestError):
                bestError = curError
                bestPick.clkdiv = curClkDiv
                bestPick.fbmult = curFb
                bestPick.maindiv = curDiv
                bestPick.freq = curFreq

            if (curError > 0):
                freq_found = 1
            

            log.debug("freq_found = {}".format(freq_found))

            curFb += 1

        curDiv += 1

    return bestPick



def dglnt_dynclk_get_rate(rate: int, parent_rate: int) -> dglnt_dynclk_mode:

    if parent_rate == 0 or rate == 0:
        return None

    rate = (rate + 100) // 200
    parent_rate =(parent_rate + 500) // 1000

    # log.debug(rate, parent_rate)

    clkMode = dglnt_dynclk_find_mode(rate, parent_rate)

    return clkMode


def dglnt_dynclk_get_reg(clkReg:dglnt_dynclk_reg) -> dict:

    # Address -> Data
    reg_map = {
        DDYNCLK_CLK_L: clkReg.clk0L,
        DDYNCLK_CLK_L: clkReg.clkFBL,
        DDYNCLK_FB_H_CLK_H: clkReg.clkFBH_clk0H,
        DDYNCLK_DIV: clkReg.divclk,
        DDYNCLK_LOCK_L: clkReg.lockL,
        DDYNCLK_FLTR_LOCK_H: clkReg.fltr_lockH
    }

    ret = {}
    for key, val in reg_map.items():
        ret[hex(key)] = hex(val)

    return ret


################################################

# clkMode = dglnt_dynclk_get_rate(int(90e6), int(100e6))
# regMap = dglnt_dynclk_get_reg(clkMode)

# for key, val in regMap.items():
#     log.debug(hex(key), " : ", hex(val))

################################################

log.basicConfig(
    format="[%(levelname)s] {%(pathname)s:%(lineno)d} - %(message)s", 
    # level=log.DEBUG
    )


# for target_freq in range(50_000_000, 1000_000_000, 10_000_000):

# mode_map = {}
# for target_freq in range(1, 50_000_000, 10_000):

#     print("======================")
#     print("target_freq", target_freq)


#     clkMode = dglnt_dynclk_get_rate(target_freq, int(100e6))
#     clkReg = dglnt_dynclk_find_reg(clkMode)
#     regMap = dglnt_dynclk_get_reg(clkReg)

#     print(clkMode)
#     # print(clkReg)
#     # print(regMap)

#     if clkMode not in mode_map:
#         mode_map[clkMode] = [target_freq]

#     print("======================")



# Display vMode Freq = 33.000000
# clkMode: freq=33.000000 fbmult=33 clkdiv=5 maindiv=4
# Display pxlFreq = 33.000000
# clkReg: clk0L=8388739 clkFBL=8389649 clkFBH_clk0H=0 divclk=130 lockL=3536823297 fltr_lockH=6488319


clkMode = dglnt_dynclk_get_rate(33, int(100e6))
clkReg = dglnt_dynclk_find_reg(clkMode)
regMap = dglnt_dynclk_get_reg(clkReg)

print(clkMode)
print(clkReg)
print(regMap)


clkMode.freq = 33
clkMode.fbmult = 33
clkMode.clkdiv = 5
clkMode.maindiv = 4
clkReg = dglnt_dynclk_find_reg(clkMode)

print(clkReg)