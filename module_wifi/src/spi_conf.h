/*
 * SPI clock frequency = (100 MHz)/(2 * DEFAULT_SPI_CLOCK_DIV)
 *                     = (100 MHz)/(2 * 4)
 *                     = 12.5 MHz
 * */
#define DEFAULT_SPI_CLOCK_DIV 4

/*
 * SPI Master Mode = 1
 * CPHA 1; CPOL 0
 */
#define SPI_MASTER_MODE 1
