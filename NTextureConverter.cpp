#include "NTextureConverter.h"

void NTextureConverter::ConvertTextureWICToDDS(const std::string& filePath, int numOptions, char* options[])
{
	//テクスチャ読み込み
	LoadWICTextureFromFile(filePath);

	//DDS形式に変換して書き出し
	SaveDDSTextureToFile(numOptions,options);
}

void NTextureConverter::OutputUsage()
{
	printf("画像ファイルをWIC形式からDDS形式に変換します。\n");
	printf("\n");	//空白行
	printf("TextureConverter[ドライブ:][パス][ファイル名]\n");
	printf("\n");	//空白行
	printf("[ドライブ:][パス][ファイル名]：変換したいWIC形式の画像ファイルを指定します。\n");
	printf("\n");	//空白行
	printf("[プロジェクトのプロパティ]→[デバッグ]→[コマンド引数]のパスの末尾に\n");
	printf("「半角スペース」「-ml」「半角スペース」「ミップレベル」を入力することでミップレベルを指定できます。\n");
	printf("0を指定することで1×1までのフルミップマップチェーンを生成します。\n");
	printf("\n");	//空白行
}

void NTextureConverter::LoadWICTextureFromFile(const std::string& filePath)
{
	//ファイルパスをワイド文字に変換
	std::wstring wFilePath = ConvertMultiByteStringToWideString(filePath);

	//WICテクスチャのロード
	HRESULT result;
	result = DirectX::LoadFromWICFile(wFilePath.c_str(), DirectX::WIC_FLAGS_NONE, &metadata_, scratchImage_);
	assert(SUCCEEDED(result));

	//フォルダパスとファイル名を分離する
	SeparateFilePath(wFilePath);

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

void NTextureConverter::SeparateFilePath(const std::wstring& filePath)
{
	size_t pos1;
	std::wstring exceptExt;

	//区切り文字'.'が出てくる一番最後の部分を検索
	pos1 = filePath.rfind('.');
	//検索がヒットしたら
	if (pos1 != std::wstring::npos)
	{
		//区切り文字の後ろをファイル拡張子として保存
		fileExt_ = filePath.substr(pos1 + 1, filePath.size() - pos1 - 1);
		//区切り文字の前までを抜き出す
		exceptExt = filePath.substr(0, pos1);
	}
	else
	{
		fileExt_ = L"";
		exceptExt = filePath;
	}

	//区切り文字'\\'が出てくる一番最後の部分を検索
	pos1 = exceptExt.rfind('\\');
	if (pos1!=std::wstring::npos)
	{
		//区切り文字の前までをディレクトリパスとして保存
		directoryPath_ = exceptExt.substr(0, pos1 + 1);
		//区切り文字の後ろをファイル名として保存
		fileName_ = exceptExt.substr(pos1 + 1, exceptExt.size() - pos1 - 1);
		return;
	}

	//区切り文字'/'が出てくる一番最後の部分を検索
	pos1 = exceptExt.rfind('/');
	if (pos1!=std::wstring::npos)
	{
		//区切り文字の前までをディレクトリパスとして保存
		directoryPath_ = exceptExt.substr(0, pos1 + 1);
		//区切り文字の後ろをファイル名として保存
		fileName_ = exceptExt.substr(pos1 + 1, exceptExt.size() - pos1 - 1);
		return;
	}

	//区切り文字がないのでファイル名のみとして扱う
	directoryPath_ = L"";
	fileName_ = exceptExt;
}

void NTextureConverter::SaveDDSTextureToFile(int numOptions, char* options[])
{
	size_t mipLevel = 0;

	//ミップマップレベル指定を検索
	for (int i = 0; i < numOptions; i++)
	{
		if (std::string(options[i]) == "-ml")
		{
			//ミップレベル指定
			mipLevel = std::stoi(options[i + 1]);
			break;
		}
	}

	HRESULT result;

	//ミップマップ生成
	DirectX::ScratchImage mipChain;
	result = GenerateMipMaps(
		scratchImage_.GetImages(), scratchImage_.GetImageCount(),
		scratchImage_.GetMetadata(), DirectX::TEX_FILTER_DEFAULT, mipLevel, mipChain);

	if (SUCCEEDED(result))
	{
		//イメージとメタデータを、ミップマップ版で置き換える
		scratchImage_ = std::move(mipChain);
		metadata_ = scratchImage_.GetMetadata();
	}

	//読み込んだディフューズテクスチャをSRGBとして扱う
	metadata_.format = DirectX::MakeSRGB(metadata_.format);

	//出力ファイル名を設定する
	std::wstring filePath = directoryPath_ + fileName_ + L".dds";

	//DDSファイル書き出し
	result = DirectX::SaveToDDSFile(
		scratchImage_.GetImages(), scratchImage_.GetImageCount(), metadata_,
		DirectX::DDS_FLAGS_NONE, filePath.c_str());
	assert(SUCCEEDED(result));
}
