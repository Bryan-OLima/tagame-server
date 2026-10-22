import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import {
  IconActivity,
  IconArrowRight,
  IconClipboardList,
  IconDeviceDesktop,
  IconDeviceGamepad2,
  IconDotsVertical,
  IconFileText,
  IconHierarchy3,
  IconHome,
  IconLogout,
  IconMenu2,
  IconNfc,
  IconPlayerPlay,
  IconSend,
  IconServer2,
  IconSettings,
  IconTag,
  TablerIconComponent,
  type TablerIcon,
} from '@tabler/icons-angular';

type Role = 'admin' | 'guest';
type PreviewState = 'live' | 'loading' | 'empty' | 'error';

interface NavigationItem {
  label: string;
  icon: TablerIcon;
  adminOnly?: boolean;
}

@Component({
  imports: [CommonModule, TablerIconComponent],
  selector: 'app-root',
  styleUrl: './app.css',
  templateUrl: './app.html',
})
export class App {
  // The development entry point opens the approved dashboard composition directly.
  // The access placeholder remains available through the prototype sign-out action.
  protected readonly authenticated = signal(true);
  protected readonly role = signal<Role>('admin');
  protected readonly menuOpen = signal(false);
  protected readonly previewState = signal<PreviewState>('live');
  protected readonly activePage = signal('Dashboard');

  protected readonly navigation: readonly NavigationItem[] = [
    { label: 'Dashboard', icon: IconHome },
    { label: 'Jogos', icon: IconDeviceGamepad2 },
    { label: 'Tags NFC', icon: IconNfc },
    { label: 'Leitores', icon: IconActivity, adminOnly: true },
    { label: 'PCs e agentes', icon: IconDeviceDesktop, adminOnly: true },
    { label: 'Sessões', icon: IconPlayerPlay },
    { label: 'Usuários', icon: IconHierarchy3, adminOnly: true },
    { label: 'Auditoria', icon: IconFileText, adminOnly: true },
  ];

  protected readonly icons = {
    activity: IconActivity,
    arrowRight: IconArrowRight,
    clipboard: IconClipboardList,
    desktop: IconDeviceDesktop,
    gamepad: IconDeviceGamepad2,
    dots: IconDotsVertical,
    logout: IconLogout,
    menu: IconMenu2,
    nfc: IconNfc,
    play: IconPlayerPlay,
    send: IconSend,
    server: IconServer2,
    settings: IconSettings,
    tag: IconTag,
  } as const;

  protected enter(role: Role): void { this.role.set(role); this.authenticated.set(true); }
  protected leave(): void { this.authenticated.set(false); this.menuOpen.set(false); }
  protected selectPage(label: string): void { this.activePage.set(label); this.menuOpen.set(false); }
  protected setPreviewState(state: PreviewState): void { this.previewState.set(state); }
  protected toggleMenu(): void { this.menuOpen.update((isOpen) => !isOpen); }
}
