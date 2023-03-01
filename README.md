# sfPrep
Some pipeline for MRI processing.

# Notes

qsiprep-0.16.1中--skip-bids-validation参数无效；

做完preprocessing后，在recon时，要将qsiprep文件夹作为--recon-input参数的输入；

命令行里面所有的路径可能需要指定为绝对路径，待测试；（绝对路径可以生成figure文件；）