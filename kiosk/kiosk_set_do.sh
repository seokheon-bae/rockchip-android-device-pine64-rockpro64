#!/system/bin/sh
# /system/bin/kiosk_set_do.sh  —— 等所有使用者帳號穩定為 0 才設 DO
PATH=/system/bin:/system/xbin:/product/bin:/vendor/bin:$PATH
PKG="com.asus.tinker_launcher"
ADMIN="$PKG/.MyDeviceAdminReceiver"
TAG="KioskDO"

QUIET_SECONDS=10    # 連續幾秒帳號總數為 0 才算穩定
TOTAL_TIMEOUT=360   # 最多等幾秒（整體）

log -t "$TAG" "--- kiosk_set_do.sh start ---"

# 等 device_policy service 就緒（最多 30s）
for i in $(seq 1 30); do
  if service check device_policy >/dev/null 2>&1; then break; fi
  sleep 0.5
done

# 選擇 DPM 介面：優先用獨立 dpm；否則 cmd device_policy
if [ -x /system/bin/dpm ]; then
  DPM="/system/bin/dpm"
elif cmd -l 2>/dev/null | grep -qx 'device_policy'; then
  DPM="cmd device_policy"
else
  log -t "$TAG" "No DPM interface (dpm/cmd device_policy). Abort."
  exit 1
fi

get_do_component() {
	# 先嘗試：從「Device Owner:」到下一段標題「Enabled Device Admins」的區塊
  out="$(dumpsys device_policy 2>/dev/null \
        | sed -n '/^[[:space:]]*Device Owner:/,/^[[:space:]]*Enabled Device Admins/p' \
        | grep -m1 -o 'admin=ComponentInfo{[^}]*}' \
        | sed -n 's/.*{\(.*\)}.*/\1/p')"

  # 備援：從「Device Owner:」到下一個空白行
  if [ -z "$out" ]; then
    out="$(dumpsys device_policy 2>/dev/null \
          | sed -n '/^[[:space:]]*Device Owner:/,/^$/p' \
          | grep -m1 -o 'admin=ComponentInfo{[^}]*}' \
          | sed -n 's/.*{\(.*\)}.*/\1/p')"
  fi

  # 仍然空 → 回傳 "null"
  [ -z "$out" ] && out="null"
  printf '%s\n' "$out"
}

PKG="com.asus.tinker_launcher"
ADMIN="$PKG/$PKG.MyDeviceAdminReceiver"

# 已有 DO 就跳過
EXISTING="$(get_do_component)"
log -t "$TAG" "existing_do=$EXISTING"
if [ "$EXISTING" = "$ADMIN" ]; then
  OUT="$($DPM set-device-owner --user 0 "$ADMIN" 2>&1)"; RC=$?
  log -t "$TAG" "set-device-owner rc=$RC, out=$OUT"
  exit $RC
fi

# 確認 DPC 存在
pm list packages "$PKG" >/dev/null 2>&1 || { log -t "$TAG" "Package $PKG not found"; exit 1; }

# 若啟用 headless system user，常見會有 user 10 跑著；先嘗試停掉非 0 使用者（可忽略失敗）
for u in $(pm list users | awk -F'[{}=, ]' '/UserInfo/{print $3}' | grep -v '^0$'); do
  log -t "$TAG" "trying to stop user $u"
  am stop-user -w "$u" >/dev/null 2>&1 || true
done

# 計算所有使用者帳號總數
accounts_total() {
  tot=0
  for u in $(pm list users | awk -F'[{}=, ]' '/UserInfo/{print $3}'); do
    c=$(dumpsys account --user "$u" 2>/dev/null | grep -c 'Account { name=' || true)
    log -t "$TAG" "user=$u accounts=$c"
    tot=$((tot + c))
  done
  echo "$tot"
}

# 等待「連續 QUIET_SECONDS 秒」帳號總數為 0（最多 TOTAL_TIMEOUT 秒）
wait_accounts_quiet() {
  steady=0; waited=0
  while [ $waited -lt $TOTAL_TIMEOUT ]; do
    n=$(accounts_total)
    log -t "$TAG" "accounts_total=$n (steady=$steady/$QUIET_SECONDS)"
    if [ "$n" -eq 0 ]; then
      steady=$((steady + 1))
      [ $steady -ge $QUIET_SECONDS ] && return 0
    else
      steady=0
    fi
    sleep 0.5
    waited=$((waited + 1))
  done
  return 1
}

if ! wait_accounts_quiet; then
  log -t "$TAG" "Accounts never quiesced to zero (timeout ${TOTAL_TIMEOUT}s). DO may be rejected."
fi

# 設為 Device Owner（Android 14/headless → 指定 user 0）
OUT="$($DPM set-device-owner --user 0 "$ADMIN" 2>&1)"
RC=$?
log -t "$TAG" "set-device-owner rc=$RC, out=$OUT"
exit $RC
