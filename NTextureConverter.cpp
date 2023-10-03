#include "NTextureConverter.h"

#include <DirectXTex.h>

void NTextureConverter::ConvertTextureWICToDDS(const std::string& filePath)
{
	//�e�N�X�`���ǂݍ���
	LoadWICTextureFromFile(filePath);

	//DDS�`���ɕϊ����ď����o��
}

void NTextureConverter::LoadWICTextureFromFile(const std::string& filePath)
{
	std::wstring wFilePath = ConvertMultiByteStringToWideString(filePath);
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
