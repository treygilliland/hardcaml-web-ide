import { useEffect } from "react";
import styles from "./Toast.module.scss";

export interface ToastProps {
  message: string;
  type?: "error" | "warning" | "info";
  onDismiss: () => void;
  autoDismissMs?: number;
}

export function Toast({
  message,
  type = "error",
  onDismiss,
  autoDismissMs = 5000,
}: ToastProps) {
  useEffect(() => {
    if (autoDismissMs > 0) {
      const timer = setTimeout(onDismiss, autoDismissMs);
      return () => clearTimeout(timer);
    }
  }, [autoDismissMs, onDismiss]);

  const typeClassMap: Record<"error" | "warning" | "info", string> = {
    error: styles.error,
    warning: styles.warning,
    info: styles.info,
  };

  return (
    <div className={styles.overlay} onClick={onDismiss}>
      <div
        className={`${styles.toast} ${typeClassMap[type]}`}
        onClick={(e) => e.stopPropagation()}
      >
        <span className={styles.message}>{message}</span>
        <button className={styles.closeButton} onClick={onDismiss}>
          ×
        </button>
      </div>
    </div>
  );
}
