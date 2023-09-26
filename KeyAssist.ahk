#NoEnv
#NoTrayIcon
#SingleInstance Force

#UseHook
#InputLevel 50

SetStoreCapslockMode,off
SetTitleMatchMode,RegEx

#Include <Application>
#Include <KeyMap>
#Include <InI>

Process, Priority,, High

new @LOG(A_WorkingDir "\log.txt")
;KeyState.toggle["Log"]:=1
$main(){
	if(Application.Config.Config.LongMappingDetectionDelay){
		KeyMap.LongMappingDetectionDelay := Application.Config.Config.LongMappingDetectionDelay
	}
	SetWorkingDir % Application.Config.Config.Directory

	loop,Files,*,D 
	{
		loop,Files, %A_LoopFileFullPath%\*.ini,R
		{
			new KeyMap(A_LoopFileFullPath)
		}
	}
	loop,Files,*.ini 
	{
		new KeyMap(A_LoopFileFullPath)
	}

	for k,v in KeyMap.Modifier{
		for k,v in v{
			v.OnSuccess(new Success(k))
		}
	}
}
$main()

Class Success{
	__New(key){
		this.out:=Application.Config.Modifier[SubStr(key,2,StrLen(key)-4)]
	}
	Call(){
		Send % this.out
	}
}

ResetToggle(){
	for key,value in KeyState.toggle {
		KeyState.toggle[key]:=0
	}
}