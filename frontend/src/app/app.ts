import { CommonModule } from '@angular/common';
import { Component, computed, signal } from '@angular/core';
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
  group: 'primary' | 'secondary';
}

@Component({
  imports: [CommonModule, TablerIconComponent],
  selector: 'app-root',
  styleUrls: ['./app.css', './sidebar.css', './header.css', './dashboard.css'],
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
    { label: 'Dashboard', icon: IconHome, group: 'primary' },
    { label: 'Games', icon: IconDeviceGamepad2, group: 'primary' },
    { label: 'NFC Tags', icon: IconTag, group: 'primary' },
    { label: 'Automation', icon: IconHierarchy3, group: 'primary' },
    { label: 'Settings', icon: IconSettings, group: 'primary' },
    { label: 'System', icon: IconServer2, group: 'secondary' },
    { label: 'Logs', icon: IconFileText, group: 'secondary' },
  ];

  protected readonly guestNavigation: readonly NavigationItem[] = [
    { label: 'Dashboard', icon: IconHome, group: 'primary' },
    { label: 'Jogos', icon: IconDeviceGamepad2, group: 'primary' },
    { label: 'Tags NFC', icon: IconNfc, group: 'primary' },
    { label: 'Sessões', icon: IconPlayerPlay, group: 'primary' },
  ];

  protected readonly visibleNavigation = computed(() =>
    this.role() === 'admin' ? this.navigation : this.guestNavigation,
  );

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
