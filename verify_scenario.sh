#!/bin/bash
set -e

# 清理并创建测试目录
rm -rf verify_test
mkdir verify_test
cd verify_test

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
# 记录 Checkpoint 的 Hash 和文件内容
CHECKPOINT_HASH=$(git rev-parse HEAD)
echo "Checkpoint Hash: $CHECKPOINT_HASH"

# 3. 切换到feat 分支,修改内容, push 到 远程 ,merge 到dev分支. push到远程
# (这里模拟本地操作，省略实际的 push，因为逻辑是一样的)
echo "=== 步骤 3: Feat 修改并 Merge 到 Dev ==="
git checkout feat
echo "Feat Content V1" > feat.txt
git add feat.txt
git commit -m "3. Feat V1"

# Merge feat into dev
git checkout dev
git merge feat -m "3. Merge Feat V1 into Dev"

# 4. 此时发现dev的代码有问题,切回feat 分支, reset -soft回滚,修改内容后,git push -f 推送分支
echo "=== 步骤 4: Feat 回滚并重写 ==="
git checkout feat
# reset --soft 回滚上一次提交
git reset --soft HEAD~1
echo "Feat Content V2 (Fixed)" > feat.txt
git add feat.txt
git commit -m "4. Feat V2 (Fixed)"
# 此时 Feat 分支历史改变了 (模拟 push -f)

# 5. 切换dev分支, merge 最新的feat分支 into dev.然后再git push -f dev分支
echo "=== 步骤 5: Merge 新 Feat 到 Dev ==="
git checkout dev
# 尝试 Merge。由于历史分叉，这里可能会有冲突，或者自动合并
# Feat V1 (in Dev history) vs Feat V2 (in Feat branch)
# 它们修改了同一个文件 feat.txt。
# 如果是修改同一行，会冲突。如果 reset --soft 只是重新提交，内容可能不同。
# 让我们看看 merge 结果。
if git merge feat -m "5. Merge Feat V2 into Dev"; then
    echo "Merge 成功 (无冲突)"
else
    echo "Merge 遇到冲突 (预期内)，尝试解决..."
    # 模拟解决冲突：使用 V2 的版本
    echo "Feat Content V2 (Fixed)" > feat.txt
    git add feat.txt
    git commit -m "5. Merge Feat V2 into Dev (Resolved)"
fi

echo "=== 验证结果 ==="
echo "检查 checkpoint.txt 是否存在..."
if [ -f checkpoint.txt ]; then
    echo "SUCCESS: checkpoint.txt 依然存在。"
    cat checkpoint.txt
else
    echo "FAILURE: checkpoint.txt 丢失了！"
fi

echo "检查 Git Log..."
git log --oneline --graph --all
