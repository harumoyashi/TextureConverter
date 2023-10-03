#include "NTextureConverter.h"

#include <DirectXTex.h>

void NTextureConverter::ConvertTextureWICToDDS(const std::string& filePath)
{
	//テクスチャ読み込み
	LoadWICTextureFromFile(filePath);

	//DDS形式に変換して書き出し
}

void NTextureConverter::LoadWICTextureFromFile(const std::string& filePath)
{
	std::wstring wFilePath = ConvertMultiByteStringToWideString(filePath);
}

std::wstring NTextureConverter::ConvertMultiByteStringToWideString(const std::string& mString)
{
	//ワイド文字列に変換した際の文字数を計算
	int buffSize = MultiByteToWideChar(CP_ACP, 0U, mString.c_str(), -1, nullptr, 0);

	//ワイド文字列
	std::wstring wString;
	wString.resize(buffSize);

	//ワイド文字列に変換
	MultiByteToWideChar(CP_ACP, 0, mString.c_str(), -1, &wString[0], buffSize);

	return wString;
}
