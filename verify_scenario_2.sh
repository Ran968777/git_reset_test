#!/bin/bash
set -e

# 清理并创建测试目录
rm -rf verify_test_2
mkdir verify_test_2
cd verify_test_2

echo "=== 初始化环境 ==="
git init
git config user.email "test@example.com"
git config user.name "Test User"

# 1. 首次提交, master分支,跟再此处创建dev , feat分支
echo "Initial Content" > main.txt
git add main.txt
git commit -m "1. Initial Commit"
git branch dev
git branch feat

# 2. 切换到dev分支, 修改内容,再次提交(这里记录为一个checkpoint)
echo "=== 步骤 2: Dev Checkpoint ==="
git checkout dev
echo "Checkpoint Content in Dev" > checkpoint.txt
git add checkpoint.txt
git commit -m "2. Dev Checkpoint"
# 记录 Checkpoint 的 Hash
CHECKPOINT_HASH=$(git rev-parse HEAD)
echo "Checkpoint Hash: $CHECKPOINT_HASH"

# 3. 切换到feat 分支,修改内容, push 到 远程 ,merge 到dev分支. push到远程
# (模拟远程交互：这里不需要真的远程仓库，只要模拟本地分支状态即可)
echo "=== 步骤 3: Feat 修改并 Merge 到 Dev ==="
git checkout feat
echo "Feat Content V1" > feat.txt
git add feat.txt
git commit -m "3. Feat V1"

# Merge feat into dev
git checkout dev
git merge feat -m "3. Merge Feat V1 into Dev"
# 模拟 push dev (本地 dev 现在包含 Checkpoint 和 Feat V1)

# 4. 此时发现dev的代码有问题,切回feat 分支, reset -soft回滚,修改内容后,git push -f 推送分支
echo "=== 步骤 4: Feat 回滚并重写 ==="
git checkout feat
# reset --soft 回滚上一次提交
git reset --soft HEAD~1
echo "Feat Content V2 (Fixed)" > feat.txt
git add feat.txt
git commit -m "4. Feat V2 (Fixed)"
# 模拟 push -f feat (此时 feat 分支历史改变，不再包含 Feat V1)

# 5. 切换dev分支.然后再git push -f dev分支
echo "=== 步骤 5: 切换 Dev 并 Push -f ==="
git checkout dev
# 注意：这里直接切换回 Dev。Dev 分支目前仍然停留在步骤 3 结束时的状态。
# 也就是包含 Checkpoint 和 Feat V1 (通过 Merge Commit)。
# 执行 git push -f dev (模拟)。
# 由于本地 Dev 没有被修改过，它依然指向 M1。

echo "=== 验证结果 ==="
echo "检查 checkpoint.txt 是否存在..."
if [ -f checkpoint.txt ]; then
    echo "SUCCESS: checkpoint.txt 依然存在。"
    cat checkpoint.txt
else
    echo "FAILURE: checkpoint.txt 丢失了！"
fi

echo "检查 Git Log (Dev 分支)..."
git log --oneline --graph -n 5

echo "检查 Git Log (Feat 分支)..."
git checkout feat 2>/dev/null
git log --oneline --graph -n 5
