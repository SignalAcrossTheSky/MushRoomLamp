typedef NS_ENUM(NSInteger, INTERFACE_TYPE) {
    INTERFACE_TYPE_MESSAGECODE      = 0x000,   /** 发送验证码网络请求 */
    INTERFACE_TYPE_REGISTER         = 0x001,   /** 注册网络请求      */
    INTERFACE_TYPE_LOGIN            = 0x002,   /** 登录网络请求      */
    INTERFACE_TYPE_ADDEQUIPMENT     = 0x003,   /** 注册新的设备网络请求 */
    INTERFACE_TYPE_FORGETPWD        = 0x004,   /** 忘记密码网络请求 */
    INTERFACE_TYPE_DEVICELIST       = 0x005,   /** 获取设备列表的网络请求 */
    INTERFACE_TYPE_RENAME           = 0x006,   /** 重命名设备网络请求  */
    INTERFACE_TYPE_ADBOUTPRODUCT    = 0x007,   /** 关于产品网络请求  */
    INTERFACE_TYPE_RETURNQUESTION   = 0x008,   /** 问题反馈网络请求 */
    INTERFACE_TYPE_CHARTDATE        = 0x009,   /** 图表数据网络请求  */
    INTERFACE_TYPE_LAMPSETTING      = 0x010,   /** 获取灯的设置信息网络请求 */
    INTERFACE_TYPE_SETLAMP          = 0x011,   /** 设置灯的网络请求 */
    INTERFACE_TYPE_DELETELAMP       = 0x012,   /** 删除灯的网络请求 */
    INTERFACE_TYPE_FEEDBACK         = 0x013,   /** 意见反馈的网络请求 */
    INTERFACE_TYPE_QIUT             = 0x014,   /** 退出登录的网络请求 */
    INTERFACE_TYPE_OUTDOORWEATHER   = 0x015,   /** 户外天气网络请求 */
    INTERFACE_TYPE_ALARMCLOCKLIST   = 0x016,   /** 闹钟列表网络请求 */
    INTERFACE_TYPE_ENVIRONMENTREPORT = 0x017,  /** 环境日报网络接口 */
    INTERFACE_TYPE_OPENALARMCLOCK   = 0x018,   /** 开关闹钟网络接口 */
    INTERFACE_TYPE_ADDALARMCLOCK    = 0x019,   /** 添加闹钟网络接口 */
    INTERFACE_TYPE_MODIFYALARMCLOCK = 0x020,   /** 修改闹钟网络接口 */
    INTERFACE_TYPE_REMOVEALARMCLOCK = 0x021,   /** 移除闹钟网络接口 */
};
