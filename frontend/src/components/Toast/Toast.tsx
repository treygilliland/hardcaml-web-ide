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

  return (
    <div className={styles.overlay} onClick={onDismiss}>
      <div
        className={`${styles.toast} ${styles[type]}`}
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
