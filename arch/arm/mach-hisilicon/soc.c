#include <asm/io.h>

#define SOC_SN_LEN 24
#define SOC_ID_LEN 4

static char g_soc_sn[SOC_SN_LEN] = {0};
static char g_soc_id[SOC_ID_LEN] = {0};

const char *soc_get_sn(int *len)
{
    uint32_t sn_reg_start = 0x12020400;
    for (int i = 0; i < 6; i ++) // soc sn saves in 6 registers, each register saves 4 bytes
    {
        uint32_t reg_val = readl(sn_reg_start + i * 4);
        g_soc_sn[i * 4] = reg_val & 0xFF;
        g_soc_sn[i * 4 + 1] = (reg_val >> 8) & 0xFF;
        g_soc_sn[i * 4 + 2] = (reg_val >> 16) & 0xFF;
        g_soc_sn[i * 4 + 3] = (reg_val >> 24) & 0xFF;
    }

    *len = SOC_SN_LEN;
    return g_soc_sn;
}

const char* soc_get_id(int *len)
{
    uint32_t id_reg_start = 0x12020EE0;
    uint32_t reg_val = readl(id_reg_start);
    g_soc_id[0] = reg_val & 0xFF;
    g_soc_id[1] = (reg_val >> 8) & 0xFF;
    g_soc_id[2] = (reg_val >> 16) & 0xFF;
    g_soc_id[3] = (reg_val >> 24) & 0xFF;

    *len = SOC_ID_LEN;
    return g_soc_id;
}