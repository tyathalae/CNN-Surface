require 'torch'
require 'xlua'
require 'image'
require 'nn'

-- To load a directory of images into a table
function LoadImages(directory, extension)
	local images = {}
	local files = GetImagesInDirectory(directory, extension)
	
	-- Debug
	--print('Found files: ')
	--print(files)

	for i, file in ipairs(files) do
		table.insert(images, image.load(file))
	end

	-- Debug
	--print('Loaded images: ')
	--print(images)
	return images
end

function GetImagesInDirectory(directory, extension)
	local imagePaths = {}
	
	for file in paths.files(directory) do
		if file:find(extension .. '$') then
			table.insert(imagePaths, paths.concat(directory, file))
		end
	end

	if #imagePaths == 0 then
		print('No files found in ' .. directory .. ' with ' .. extension .. ' extension')
		return 0
	end

	table.sort(imagePaths, function (a,b) return a < b end)
	return imagePaths
end

function TableConcat(t1,t2)
    for i = 1, #t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function GetFileName(path)
  return path:match("^.+/(.+)$")
end

function TableToTensor(table)
	local tensorSize = table[1]:size()
	--print('TableToTensor: tensorSize is ' .. tostring(tensorSize)) -- Debug
	local tensorSizeTable = {-1}
	--print('tensorSize: ' .. tensorSize:size(1)) -- Debug
	for i=1,tensorSize:size(1) do
		tensorSizeTable[i+1] = tensorSize[i]
	end
	merge=nn.Sequential()
		:add(nn.JoinTable(1))
    	:add(nn.View(unpack(tensorSizeTable)))

  return merge:forward(table)
end

-- Ratio is between 0 and 1
function SplitDataset(data, labels, ratio)
   local shuffle = torch.randperm(data:size(1))
   local numTrain = math.floor(shuffle:size(1) * ratio)
   local numTest = shuffle:size(1) - numTrain
   local trainData = torch.Tensor(numTrain, data:size(2), data:size(3), data:size(4))
   local testData = torch.Tensor(numTest, data:size(2), data:size(3), data:size(4))
   local trainLabels = torch.Tensor(numTrain)
   local testLabels = torch.Tensor(numTest)
   for i=1,numTrain do
      trainData[i] = data[shuffle[i]]:clone()
      trainLabels[i] = labels[shuffle[i]]
      --:clone()
   end
   for i=numTrain+1,numTrain+numTest do
      testData[i-numTrain] = data[shuffle[i]]:clone()
      testLabels[i-numTrain] = labels[shuffle[i]]
      --:clone()
   end
   return trainData, trainLabels, testData, testLabels
end

