#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <emitsoundany> 
#include <store>   //kyle

public Plugin myinfo =
{
	name        = "MapModeSwitch",
	author 	    = "c",
	description = "MapMode",
	version     = "1.5.0",
	url         = "https://www.csplat.cn/"
}

public OnPluginStart()
{
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end",OnRoundEnd,EventHookMode_Pre);
    //HookEvent("player_spawn", PlayerSpawn);
}


public void OnMapStart()
{
	
	// 预缓存ALL Sound 文件
	PrecacheSound("music/end/ze_pipeline_escape/fgsn.mp3", true);
	PrecacheSound("music/end/ze_pipeline_escape/qby2.mp3", true);
	PrecacheSound("music/end/ze_pipeline_escape/qby.wav", true);
	AddFileToDownloadsTable("sound/music/end/ze_pipeline_escape/fgsn.mp3");
	AddFileToDownloadsTable("sound/music/end/ze_pipeline_escape/qby2.mp3");
	AddFileToDownloadsTable("sound/music/end/ze_pipeline_escape/qby.wav");
	

    ServerCommand("mp_maxrounds 30");   
    ServerCommand("mp_autoteambalance 1");   
    ServerCommand("mp_limitteams 2");    
    ServerCommand("mp_humanteam any");    

}
	
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));
	if (StrEqual(currentMap, "ze_pipeline_escape", false))  //验证地图
	{
	if(GetClientTeam(client) == 2 & !IsFakeClient(client))
	{
		ChangeClientTeam(client, 1);
		CS_RespawnPlayer(client);
		PrintToChat(client, "[csplat.cn]本地图仅支持:[CT反恐精英队伍]进入地图游玩(T)队伍会自动切换到CT");
		PrintToChat(client, "[csplat.cn]欢迎游玩此地图,你已被切换段位为:[3]CT队伍");
}
      //SDKHook(client, SDKHook_OnTakeDamage, TakeDamageHook);
}
}



public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));
	if (StrEqual(currentMap, "ze_pipeline_escape", false))  //验证地图
	{
    ServerCommand("sm plugins unload nobots_enforcer");
    ServerCommand("mp_maxrounds 10");   
    ServerCommand("mp_autoteambalance 0");   
    ServerCommand("mp_limitteams 0");    
    ServerCommand("mp_humanteam ct");    
    ServerCommand("bot_add_t");    
    PrintToChatAll("[csplat.cn] 开启团队无限制人数!");
    for (int i = 1; i <= MaxClients; i++)
	   {
    SDKHook(i, SDKHook_OnTakeDamage, TakeDamageHook);   //HOOK Take Damage
    
    // 禁用所有游戏声音
	// https://forums.alliedmods.net/showthread.php?t=227735  Sourcemod Web
	ClientCommand(i, "playgamesound Music.StopAllMusic");
	
	
     }				
    VerifyMap();   //验证地图,发送给所有客户端消息
}
} 


public Action:TakeDamageHook(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
   char currentMap[PLATFORM_MAX_PATH];
   GetCurrentMap(currentMap, sizeof(currentMap));   
   
    if (StrEqual(currentMap, "ze_pipeline_escape", false))
	  {	  
    if ( (client>=1) && (client<=MaxClients) && (attacker>=1) && (attacker<=MaxClients) && (attacker==inflictor) )
    {
        decl String:WeaponName[64];
        GetClientWeapon(attacker, WeaponName, sizeof(WeaponName));
        if (StrEqual(WeaponName, "weapon_knife", false))
        {
            damage *= 0;
            return Plugin_Stop;
        }
     }
   }
    return Plugin_Continue;
}

public OnRoundEnd(Handle: event , const String: name[] , bool: dontBroadcast)
{
   new client = GetClientOfUserId(GetEventInt(event, "userid")); // Get Player's userid
   char currentMap[PLATFORM_MAX_PATH];
   GetCurrentMap(currentMap, sizeof(currentMap));   
   if (StrEqual(currentMap, "ze_pipeline_escape", false))
	{					
   PrintToChatAll( "[csplat.cn]  \x05因游玩此地图，每人发放[1]E点奖励！");
   PrintToChatAll("[Tips]  \x05失败别放弃，勇敢往前冲，你可以领取到属于你的奖励！");  
       for (int i = 1; i <= MaxClients; i++)
	   {
   Store_SetClientCredits(i, Store_GetClientCredits(i) + 1);  
     }
   }
   
}


public Action VerifyMap()
{
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));
	if (StrEqual(currentMap, "ze_pipeline_escape", false))
	{		
    for (int i = 1; i <= MaxClients; i++)
	   {
      new random = GetRandomInt(1,3);
      switch(random)
       {
    case 1:
      {   
  //ClientCommand(i, "play */music/end/ze_pipeline_escape/qby.wav");    // Volume High
	PrintToChatAll(" \x09[csplat.cn] CheckMap:[%s],StartDiyMode:[Entertainment mode],AreYouReady？GO！", currentMap);
	PrintToChatAll(" \x09[csplat.cn]  \x05地图%s，每个人将会获得额外积分/段位奖励![Tips:赢的人将会赢得更多积分奖励哟！冲！]", currentMap);
    PrintToChatAll(" \x09MusicName:  \x05千本樱");
    PrintToChatAll(" \x09地图来自： \x05【创意工坊】");
	EmitSoundToClient(i, "music/end/ze_pipeline_escape/qby.wav", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 50.0);
      }
 
    case 2:
      {   
  //ClientCommand(i, "play */music/end/ze_pipeline_escape/qby2.mp3");    // Volume High
	PrintToChatAll(" \x09[csplat.cn] CheckMap:[%s],StartDiyMode:[Entertainment mode],AreYouReady？GO！", currentMap);
	PrintToChatAll(" \x09[csplat.cn]  \x05地图%s，每个人将会获得额外积分/段位奖励![Tips:赢的人将会赢得更多积分奖励哟！冲！]", currentMap);
    PrintToChatAll(" \x09MusicName:  \x05千本樱2");
    PrintToChatAll(" \x09地图来自： \x05【创意工坊】");
    EmitSoundToClient(i, "music/end/ze_pipeline_escape/qby2.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 50.0);
}

    case 3:
      {   
    //ClientCommand(i, "play */music/end/ze_pipeline_escape/fgsn.mp3");   // Volume High
	PrintToChatAll(" \x09[csplat.cn] CheckMap:[%s],StartDiyMode:[Entertainment mode],AreYouReady？GO！", currentMap);
	PrintToChatAll(" \x09[csplat.cn]  \x05地图%s，每个人将会获得额外积分/段位奖励![Tips:赢的人将会赢得更多积分奖励哟！冲！]", currentMap);
    PrintToChatAll(" \x09MusicName:  \x05翻滚少女");
    PrintToChatAll(" \x09地图来自： \x05【创意工坊】");
    EmitSoundToClient(i, "music/end/ze_pipeline_escape/fgsn.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 50.0);
   }
  }
  }
 }
}