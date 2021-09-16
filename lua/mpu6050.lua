print(_VERSION)

id  = 0 -- always 0

scl = 6 -- set pin 6 as scl
sda = 7 -- set pin 7 as sda

MPU6050SlaveAddress = 0x68

--AccelScaleFactor = 16384;   -- sensitivity scale factor respective to full scale setting provided in datasheet 
-- GyroScaleFactor = 131;

-- https://invensense.tdk.com/wp-content/uploads/2015/02/MPU-6000-Register-Map1.pdf
-- https://www.youtube.com/watch?v=j-kE0AMEWy4&ab_channel=JoopBrokking
AccelScaleFactor = 4096;  --8g/s
GyroScaleFactor = 65.5; -- ± 500 °/s


MPU6050_REGISTER_SMPLRT_DIV   =  0x19
MPU6050_REGISTER_USER_CTRL    =  0x6A
MPU6050_REGISTER_PWR_MGMT_1   =  0x6B
MPU6050_REGISTER_PWR_MGMT_2   =  0x6C
MPU6050_REGISTER_CONFIG       =  0x1A
MPU6050_REGISTER_GYRO_CONFIG  =  0x1B
MPU6050_REGISTER_ACCEL_CONFIG =  0x1C
MPU6050_REGISTER_FIFO_EN      =  0x23
MPU6050_REGISTER_INT_ENABLE   =  0x38
MPU6050_REGISTER_ACCEL_XOUT_H =  0x3B
MPU6050_REGISTER_SIGNAL_PATH_RESET  = 0x68

 
function I2C_Write(deviceAddress, regAddress, data)
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER))-- set slave address and transmit direction
    then
        print("write")
        i2c.write(id, regAddress)  -- write address to slave
        i2c.write(id, data)  -- write data to slave
        i2c.stop(id)    -- send stop condition
    else
        print("I2C_Write fails")
    end
end

function I2C_Read(deviceAddress, regAddress, SizeOfDataToRead)
    response = 0;
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER))-- set slave address and transmit direction
    then
        i2c.write(id, regAddress)  -- write address to slave
        i2c.stop(id)    -- send stop condition
        i2c.start(id)   -- send start condition
        i2c.address(id, deviceAddress, i2c.RECEIVER)-- set slave address and receive direction
        response = i2c.read(id, SizeOfDataToRead)   -- read defined length response from slave
        i2c.stop(id)    -- send stop condition
        return response
    else
        print("I2C_Read fails")
    end
    return response
end

function unsignTosigned16bit(num)   -- convert unsigned 16-bit no. to signed 16-bit no.
    if num > 32768 then 
        num = num - 65536
    end
    return num
end

function MPU6050_Init() --configure MPU6050
    tmr.delay(150000) -- delay for 150 ms
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SMPLRT_DIV, 0x07)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_1, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_2, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_CONFIG, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_GYRO_CONFIG, 0x08)-- set +/-500 degree/second full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_CONFIG, 0x10)-- set +/- 8g full scale  
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_FIFO_EN, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_INT_ENABLE, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SIGNAL_PATH_RESET, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_USER_CTRL, 0x00)
end

i2c.setup(id, sda, scl, i2c.FAST)   -- initialize i2c
MPU6050_Init()
