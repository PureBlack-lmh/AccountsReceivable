# AccountsReceivable合约

​	在Xuperchain中的使用solidity进行编写的代码，并依照XuperChain下的evm进行了

solidity的一些改动，实验环境Xuperchain v3.10，使用XuperIDE进行代码的调试，但是在这里使用ganache+truffle也是可以跑通。

## 怎样使用truffle

​	先去truffle进行安装truffle：https://www.trufflesuite.com/docs/truffle/overview

在这里推荐安装node与npm后使用：

```bash
npm install -g truffle
```

进行全局安装

### 要求

- NodeJS v8.9.4 或更高版本
- Windows、Linux 或 Mac OS X

然后创建新文件夹后使用truffle init 创建空文件夹进行比对

## 怎样使用ganache



到这里进行安装：https://www.trufflesuite.com/docs/ganache/overview

根据教程进行使用

## 怎样编译

使用truffle compile 会生成abi



## 怎样部署

打开ganache使用truffle migrate进行将代码部署到本地区块链上