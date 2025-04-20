import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { RegisterComponent } from './register/register.component';
import { HomeComponent } from './home/home.component'; // get home component

const routes: Routes = [
  { path: 'register', component: RegisterComponent },
  // TODO: set up a component for this
  // { path: 'home' }, 
  { path: 'home', component: HomeComponent }, // ran ng generate home
  // redirect all other paths to /register
  { path: "**", redirectTo: '/register', pathMatch: "full" }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
