# KeyAssist 映射属于自己的快捷键方案

## 1. 开始使用

### 1.1 启动 KeyAssist.exe

> 双击 KeyAssist.exe 文件启动程序, 程序将会遍历目录下的所有.ini文件装载快捷键映射

### 1.2 应用程序配置文件 Application.Config

#### 1.2.1 [Config] 配置应用程序的相关设置

* LongMappingDetectionDelay : 进入持续映射模式的检测延迟

#### 1.2.2 [Modifier] 应用程序中独立的修饰键单独按下时的映射

* Capslock = {Esc} : 配置了Capslock组合映射时, 若按下Capslock到松开期间没有按下配置的其他按键, 将发送`<kbd>`Esc`<kbd>`

#### 1.2.3 [Control] 配置快捷键对应用程序进行相应的控制

* Modifier : 该[Control]域中所有快捷键的修饰键
* Reload : 重启程序
* AdminRun : 重新以管理员身份启动
* Suspend : 挂起程序, 等同于停止所有快捷键映射
* Pause : 暂停程序
* Edit : 编辑程序(仅开发模式有效)
* ExitApp : 退出程序
* ListHotkeys : 在控制窗口中列出显示所有的快捷键列表
* ListLines : 在控制窗口中显示代码页
* ListVars : 在控制窗口中显示所有变量
* KeyHistory : 在控制窗口中显示按键历史

#### 1.2.4 [Setting] 设置应用程序运行的相关参数

* BatchLines = 10ms : 设置脚本的执行速度, 可选毫秒或执行行数
* KeyDelay = Delay,PressDuration : 设置快捷键映射时发送键击后的延时
  * Delay: 延时毫秒 0和-1表示无延时
  * PressDuration: 按下时间, 0和-1表示无延时, 某些游戏和特殊的应用中要求每次键击按下一定的时间才能被检测.
* MouseDelay = Delay : 设置每次鼠标移动或点击后的延时
  * Delay : 延时毫秒, -1表示无延时, 0表示最小延时
* ControlDelay = Delay : 设置每次空间修改命令后的延时
  * Delay : 延时毫秒, -1表示无延时, 0表示最小延时
* WinDelay = Delay : 设置每次执行窗口相关操作后的延时
  * Delay : 延时毫秒, -1标识无延时, 0表示最小延时
* StoreCapsLockMode = On/Off : 设置每次发送键击后是否回复CapsLock的状态
* DefaultMouseSpeed = Speed : 设置移动鼠标时的默认速度
  * Speed : 0(最快) - 100(最慢)
* SendMode = Mode : 设置发送模拟键击时使用的方法
  * Mode :
    * Event : 默认使用的模式, 支持按键延迟
    * Input : 不支持按键延迟, 模拟键击期间会缓存用户的输入滞后到模拟完成. 该模式可能会让某些程序忽略快捷键
    * Play: 在启用UAC的系统中无法使用, 支持大部分游戏
* SendLevel = Level :
* InputLevel = Level :
* CapsLockState|NumLockState|ScrollLockState = State : 设置CapsLock/NumLock/ScrollLock键的状态
  * State =
    * On/1 : 按键打开状态
    * Off/0 : 按键关闭状态
    * AlwaysOn : 强制按键保持打开状态
    * AlwaysOff : 强制按键保持关闭状态

### 1.3 快捷键映射配置文件 [Filename].ini

> 按键列表 https://wyagd001.github.io/zh-cn/docs/KeyList.htm

#### 1.3.1 文件名 Filename

> Filename 为逻辑表达式, 由按键(Key)与逻辑符号构成. 其中逻辑符号 &(与); |(或); _(非); 以及小括号(())
>
> 例如: Capslock&LAlt : 表示当Capslock与左边的Alt键同时按下时
>
> 默认情况下验证Filename的逻辑结果时, 取Key的逻辑状态: 按下为True, 松开为Flase.
>
> 若Key前面带有@ 例如(@Capslock), 则取Capslock的切换状态, Capslock指示灯亮起时为True
>
> 任何键于本应用程序运行时都具有切换状态

> ++ 目前可通过@`name`获取name对应的切换态, 若name不是操作系统支持的键名, 则解析为自定义toggle。
>
> toggle态不能小于0，若为0表示false，大于0表示true
>
> 通过映射快捷键发送{@`name`} 切换name的toggle态，
>
> {@`name` `num`} 于name后面设置数字, 用于设置name的toggle值
>
> {@`name` -10} 于name后面指定负数，用于设置name的toggle减少对应数值
>
> {@`name` +10}  于name后面指定带+的数字, 用于设置name的taggle增加对应数值

#### 1.3.2 配置域 [Section]

> ini配置文件中通过[Section]组织配置文件, 现有的实现不允许同一个ini文件中的Section同名

##### 1.3.2.1 修饰符

> ~~目前Section无明显字面意义, 通过携带修饰符附加功能~~
>
> Section Name以 `:`分割为两部分, 前者如下描述该域的行为。
>
> 后者如Filename逻辑表达式，用于限定该域中的快捷键生效条件

> 若带有 (@)或(&) 修饰符, 例如 @Section 则该Section块具有持续映射模式
>
> &: 全局文件内的持续映射模式
>
> @: 该ini文件内的持续映射模式
>
> ~: 按键穿透, 该Section中的热键不影响其原功能
>
> *: 盲从模式, 该Section中的热键接受任意修饰键修饰, 且输出内容也会被修饰键修饰
>
> !: 发送模式 - SendPlay 不推荐使用, 在开启UAC的系统中无效
>
> ^: 发送模式 - SendInput 将输出内容作为Input模式发送, 不支持按键延迟, 会滞后用户输入
>
> $: 发送模式 - SendEvent 将输出内容作为按键事件发送, 支持按键延迟, 且域中的热字串使用SendEvent替换自动替换模式, Event模式下可以配合SendLevel触发其他的热键
>
> %: 原始模式 指输入的内容不被转义
>
> #: 文本模式 指输出的内容不会被转义, 同上, 不同之处在于不会尝试将字符(`r,`n, ``t` 和 ``b` 除外) 转换为键码

> ~~23.8.20: 支持通过 括号 `(level)` 设置热键的输入输出级别 (InputLevel、SendLevel)~~
>
> 23.8.22:
>
> +10: 设置输出内容的SendLevel=10
>
> -10 : 设置输入内容的InputLevel=10 (仅对Hotkey生效)
>
> (`delay`,`duration`,`Play`):支持通过括号设置输出内容每个键的行为
>
> `delay`:  毫秒表示的时间，设置每次输出按键的间隔，-1表示无延时，0表示最小延时。
>
> `duration`: 毫秒表示的时间，设置每次键击按下的时间。某些游戏和应用通过帧更新函数判断按键是否。故需要按键持续一定时间。-1表示无延时，0表示最小延时
>
> `Play`: 单词Play会将设置应用于SendPlay模式

> 23.8.21: 热字串支持^section 从而使用SendInput模式发送。不支持KeyDelay

> 23.8.21:
>
> ?: 执行模式, 解析右侧表达式并动态调用, 使用 `.`进行链式解构, 使用 `,`分割参数
>
> ```ahk
> Run,notepad.exe  ==> Run("notepad.exe")
> KeyState.GetStatus,this,Capslock ==> KeyState.GetStatus("this","Capslock")
> ```

##### 1.3.2.2 持续映射模式

> 持续映射模式: 当前文件名中仅包含单个按键(可包含修饰键), 当Filename中声明的键抬起时, 任何带有修饰符的Section块中的键处于按下状态, 则激活持续映射模式
>
> 例如:

```ini
;Capslock.ini
[@&Section]
I={Up}
T=Test
```

> Capslock.ini 文件中, 映射了Capslock+I = {Up} , 按下Capslock+I 将模拟↑键, 若按住I的情况下松开Capslock键, 将激活持续映射模式, 持续映射模式下 按下I 就会模拟发送↑键
>
> Capslock.ini文件中, 映射 T=Test, 按下Capslock+T, 保持T按下状态然后松开Capslock, 将激活持续映射模式
> 原需要Capslock+T才可输出Test, 在持续映射模式激活的情况下,直接按T即可输出Test

> 如何退出持续映射模式?: 按下Capslock键时没有按下其他配置的键, 则退出持续映射模式

##### 1.3.2.3 按键映射

```ini
;Capslock.ini
[Control]
*I={Blind}{Up}
~K={Down}
J Up={Left}
L&O={Right}
$U=u
::hlw=hello world
```

> 以上为Capslock.ini文件中的Control映射块
>
> 输出语法见顶部按键列表,单个字符可描述的key无需用{}包裹.

> {Blind}盲从模式:该模式必须声明在输出的最前面
>
> *: 通配符, 即使附加了修饰键也能激发该映射
>
> 盲从模式: 如果在发送开始时Alt/Ctrl/Shift/Win 为按下状态,则不松开这些按键
>
> 例如按下I键时,Shift键处于按下状态, 那么输出Shift+Up

> ~: 穿透模式, 热键中的原有功能不会被屏蔽

> Up: 在单键映射中, 使映射在抬起按键时触发而不是按下时

> &: 组合映射, 将两个或多个按键组合触发, 不推荐使用, 会影响按键原本功能

> $: 通常在发送了按键自身的映射中使用, 阻止模拟键击触发自己

> 热字串映射
>
> :: => 热字串模式, 默认情况实现为自动替换字符串 即输入hlw将被替换为hello world
>
> 若Section中包含 `!`修饰, 则使用SendPlay模式实现热字串
>
> 若Section中包含 `^`修饰, 则使用SendInput模式实现热字串
>
> 若Section中包含$修饰, 则使用SendEvent模式实现热字串

### 1.4 根据文件夹限定快捷键生效的窗体

> 可能的使用场景:
>
> 1. 限定配置文件只在target.exe中生效
> 2. 限定只在path/*.exe中生效
> 3. 限定只在target.exe的某些title中生效

> $=ahk_class
>
> #=ahk_id|ahk_pid
>
> @=ahk_exe

完成了Hotstring的适配, 需要求ini配置行以:开始

对ini配置文件中的key做 \t\n到制表符,换行符的适配以适应Hotstring

ini配置文件中key和value最外层的成对单双引号[",']会被忽略, 并将内容视为字符串, 不做\t\n的转换

@name与{@name state}

若name非系统预定义的键名, 则创建name对应的toggle态, 仅本应用程序内有效

> name若为系统与定义的键名, 虽然可以成功设置toggle, 但是@name总是获取系统中缓存的切换态(0|1)

{@name state}

在按键映射中通过{@name state} 设置name对应的toggle态, 若省略state则将toggle态取反, 同切换

## #. 待实现

> 待实现:

> 系统中存在{Sleep}键, 故重写{@Sleep milliscond} 用于在输入中休眠milliscond(毫秒)

> 在Send按键映射模式中, 增加变量功能
>
> {:name}读取变量
>
> {:name string}设置变量的值为string

BUG: 修饰键如 `Capslock`的 `Capslock Up`事件只会被执行一个变体

满足最前面的条件后, 后面的Capslock Up便无法触发

无法触发其他变体的持续映射模式
