#include "NTextureConverter.h"

void NTextureConverter::ConvertTextureWICToDDS(const std::string& filePath)
{
	//�e�N�X�`���ǂݍ���
	LoadWICTextureFromFile(filePath);

	//DDS�`���ɕϊ����ď����o��
	SaveDDSTextureToFile();
}

void NTextureConverter::LoadWICTextureFromFile(const std::string& filePath)
{
	//�t�@�C���p�X�����C�h�����ɕϊ�
	std::wstring wFilePath = ConvertMultiByteStringToWideString(filePath);

	//WIC�e�N�X�`���̃��[�h
	HRESULT result;
	result = DirectX::LoadFromWICFile(wFilePath.c_str(), DirectX::WIC_FLAGS_NONE, &metadata_, scratchImage_);
	assert(SUCCEEDED(result));

	//�t�H���_�p�X�ƃt�@�C�����𕪗�����
	SeparateFilePath(wFilePath);

}

std::wstring NTextureConverter::ConvertMultiByteStringToWideString(const std::string& mString)
{
	//���C�h������ɕϊ������ۂ̕��������v�Z
	int buffSize = MultiByteToWideChar(CP_ACP, 0U, mString.c_str(), -1, nullptr, 0);

	//���C�h������
	std::wstring wString;
	wString.resize(buffSize);

	//���C�h������ɕϊ�
	MultiByteToWideChar(CP_ACP, 0, mString.c_str(), -1, &wString[0], buffSize);

	return wString;
}

void NTextureConverter::SeparateFilePath(const std::wstring& filePath)
{
	size_t pos1;
	std::wstring exceptExt;

	//��؂蕶��'.'���o�Ă����ԍŌ�̕���������
	pos1 = filePath.rfind('.');
	//�������q�b�g������
	if (pos1 != std::wstring::npos)
	{
		//��؂蕶���̌����t�@�C���g���q�Ƃ��ĕۑ�
		fileExt_ = filePath.substr(pos1 + 1, filePath.size() - pos1 - 1);
		//��؂蕶���̑O�܂ł𔲂��o��
		exceptExt = filePath.substr(0, pos1);
	}
	else
	{
		fileExt_ = L"";
		exceptExt = filePath;
	}

	//��؂蕶��'\\'���o�Ă����ԍŌ�̕���������
	pos1 = exceptExt.rfind('\\');
	if (pos1!=std::wstring::npos)
	{
		//��؂蕶���̑O�܂ł��f�B���N�g���p�X�Ƃ��ĕۑ�
		directoryPath_ = exceptExt.substr(0, pos1 + 1);
		//��؂蕶���̌����t�@�C�����Ƃ��ĕۑ�
		fileName_ = exceptExt.substr(pos1 + 1, exceptExt.size() - pos1 - 1);
		return;
	}

	//��؂蕶��'/'���o�Ă����ԍŌ�̕���������
	pos1 = exceptExt.rfind('/');
	if (pos1!=std::wstring::npos)
	{
		//��؂蕶���̑O�܂ł��f�B���N�g���p�X�Ƃ��ĕۑ�
		directoryPath_ = exceptExt.substr(0, pos1 + 1);
		//��؂蕶���̌����t�@�C�����Ƃ��ĕۑ�
		fileName_ = exceptExt.substr(pos1 + 1, exceptExt.size() - pos1 - 1);
		return;
	}

	//��؂蕶�����Ȃ��̂Ńt�@�C�����݂̂Ƃ��Ĉ���
	directoryPath_ = L"";
	fileName_ = exceptExt;
}

void NTextureConverter::SaveDDSTextureToFile()
{
	//�ǂݍ��񂾃f�B�t���[�Y�e�N�X�`����SRGB�Ƃ��Ĉ���
	metadata_.format = DirectX::MakeSRGB(metadata_.format);

	HRESULT result;

	//�o�̓t�@�C������ݒ肷��
	std::wstring filePath = directoryPath_ + fileName_ + L".dds";

	//DDS�t�@�C�������o��
	result = DirectX::SaveToDDSFile(
		scratchImage_.GetImages(), scratchImage_.GetImageCount(), metadata_,
		DirectX::DDS_FLAGS_NONE, filePath.c_str());
	assert(SUCCEEDED(result));
}
