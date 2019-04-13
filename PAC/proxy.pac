
function FindProxyForURL(url, host) {
	if (host == 'music.163.com' || host == 'interface.music.163.com' || host == 'apm.music.163.com' || host == 'mam.netease.com' || host == '103.65.41.126' || host == '103.65.41.125' || host == '59.111.181.60' || host == '59.111.181.35' || host == '59.111.160.195' || host == '59.111.181.38' || host == '223.252.199.66' || host == '223.252.199.67' || host == '59.111.160.197' || host == '59.111.181.155') {
	return 'PROXY alilin.cn:9999'
	}
	return 'DIRECT'
}
