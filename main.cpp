#include <DirectXTex.h>
#include <cstdio>
#include <cstdlib>
#include <assert.h>
#include <combaseapi.h>

#include "NTextureConverter.h"

enum Argument {
	kApplicationPath,	//アプリケーションのパス
	kFilePath,			//渡されたファイルのパス

	NumArgument
};

int main(int argc,char* argv[])
{
	assert(argc >= NumArgument);

	//COMライブラリの初期化
	HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
	assert(SUCCEEDED(hr));

	//テクスチャコンバーター
	NTextureConverter converter;

	//テクスチャ変換
	converter.ConvertTextureWICToDDS(argv[kFilePath]);

	//COMライブラリの終了
	CoUninitialize();

	system("pause");
	return 0;
}