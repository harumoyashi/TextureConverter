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
	//コマンドライン引数指定なし
	if (argc < NumArgument)
	{
		//使い方を表示する
		NTextureConverter::OutputUsage();
		return 0;
	}

	
	//COMライブラリの初期化
	HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
	assert(SUCCEEDED(hr));

	//テクスチャコンバーター
	NTextureConverter converter;

	//オプションの数
	int numOptions = argc - NumArgument;
	//オプション配列(ダブルポインタ)
	char** options = argv + NumArgument;

	//テクスチャ変換
	converter.ConvertTextureWICToDDS(argv[kFilePath], numOptions, options);

	//COMライブラリの終了
	CoUninitialize();

	//system("pause");
	return 0;
}