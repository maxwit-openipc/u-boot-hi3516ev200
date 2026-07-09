#include <asm/io.h>

#define CHIP_ID_REG 0x12020EE0

#define HI3516EV200 0x3516E200
#define HI3516EV300 0x3516E300
#define HI3518EV300 0x3518E300

// SOC SN saves in 6 registers, each register saves 4 bytes
#define SN_REG_BASE 0x12020400
#define SOC_SN_LEN 24

static uint8_t g_soc_sn[SOC_SN_LEN];
const uint8_t *soc_get_sn(int *len)
{
    uint32_t sn_reg_start = SN_REG_BASE;

    for (int i = 0; i < SOC_SN_LEN / 4; i++) {
        uint32_t reg_val = readl(sn_reg_start + i * 4);
        g_soc_sn[i * 4] = reg_val & 0xFF;
        g_soc_sn[i * 4 + 1] = (reg_val >> 8) & 0xFF;
        g_soc_sn[i * 4 + 2] = (reg_val >> 16) & 0xFF;
        g_soc_sn[i * 4 + 3] = (reg_val >> 24) & 0xFF;
    }

    *len = SOC_SN_LEN;
    return g_soc_sn;
}

const char *soc_get_name(void)
{
    uint32_t soc_id;
    char *soc_name;

    soc_id = readl(CHIP_ID_REG);

	switch (soc_id) {
		case HI3516EV200:
			soc_name = "hi3516ev200";
			break;
		case HI3516EV300:
			soc_name = "hi3516ev300";
			break;
		case HI3518EV300:
			soc_name = "hi3518ev300";
			break;
		default:
			// printf("unknown chipid 0x%08X\n", soc_id);
			soc_name = NULL;
	};

    return soc_name;
}
